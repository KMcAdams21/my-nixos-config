"""
fishing_bot — Abiotic Factor auto-fishing bot
==============================================
Watches the center region of your screen for the bobber's motion,
presses the opposite WASD keys to counter the fish, and holds
Left Mouse Button when the bobber stops (reel-in phase).

Usage:
    game-bot fishing_bot
    game-bot fishing_bot --region-pct 35 --still-frames 6
    game-bot fishing_bot --debug      # prints live direction to terminal

Controls (set by runner):
    F8     — toggle on / off
    Ctrl+C — quit

The screen capture region is always the center N% of your monitor,
so it works on any resolution (including 4K) without calibration.
The bobber is the only moving object in that region while you fish,
so frame-differencing reliably tracks its direction.
"""

import time
import threading
import numpy as np
from pynput.keyboard import Key, Controller as KbController
from pynput.mouse import Button, Controller as MouseController

# ──────────────────────────────────────────────────────────────────────────────
# Direction maps
# ──────────────────────────────────────────────────────────────────────────────

# 8-compass directions → WASD keys to press for that direction
# (we press the OPPOSITE of the detected fish direction)
_DIR_KEYS: dict[str, tuple[str, ...]] = {
    "N":  ("w",),
    "NE": ("w", "d"),
    "E":  ("d",),
    "SE": ("s", "d"),
    "S":  ("s",),
    "SW": ("s", "a"),
    "W":  ("a",),
    "NW": ("w", "a"),
}

_OPPOSITE: dict[str, str] = {
    "N": "S", "NE": "SW", "E":  "W",  "SE": "NW",
    "S": "N", "SW": "NE", "W":  "E",  "NW": "SE",
}

_ALL_MOVE_KEYS = ("w", "a", "s", "d")


# ──────────────────────────────────────────────────────────────────────────────
# Argument declarations
# ──────────────────────────────────────────────────────────────────────────────

def add_args(parser):
    parser.add_argument(
        "--region-pct", type=int, default=30, metavar="N",
        help="Center region size as %% of screen (default: 30). "
             "On 4K this is ~1150×650 px.",
    )
    parser.add_argument(
        "--pixel-thresh", type=int, default=25, metavar="N",
        help="Min per-channel pixel delta to count as movement (default: 25).",
    )
    parser.add_argument(
        "--motion-thresh", type=int, default=40, metavar="N",
        help="Min number of changed pixels to declare fish pulling (default: 40).",
    )
    parser.add_argument(
        "--still-frames", type=int, default=8, metavar="N",
        help="Consecutive still frames before switching to reel-in (default: 8).",
    )
    parser.add_argument(
        "--fps", type=int, default=20, metavar="N",
        help="Screen-capture rate in frames per second (default: 20).",
    )
    parser.add_argument(
        "--debug", action="store_true",
        help="Print detected direction + motion pixel count each tick.",
    )
    parser.add_argument(
        "--test-capture", action="store_true",
        help="Save one screenshot to /tmp/fishing_capture.png and exit. "
             "Run this first to verify mss can see your game.",
    )


# ──────────────────────────────────────────────────────────────────────────────
# Screen capture helper
# ──────────────────────────────────────────────────────────────────────────────

def _get_center_region(pct: int):
    """
    Return the mss monitor dict for the center N% of the primary screen.
    Also returns (cx, cy) the center pixel coordinates.
    """
    import mss
    with mss.mss() as sct:
        mon = sct.monitors[1]          # primary monitor
    sw, sh = mon["width"], mon["height"]
    rw = int(sw * pct / 100)
    rh = int(sh * pct / 100)
    left = mon["left"] + (sw - rw) // 2
    top  = mon["top"]  + (sh - rh) // 2
    return {"left": left, "top": top, "width": rw, "height": rh}, rw // 2, rh // 2


def _capture(sct, region) -> np.ndarray:
    """Capture region and return as HxWx3 uint8 numpy array (RGB)."""
    raw = sct.grab(region)
    # mss returns BGRA; drop alpha, keep BGR (doesn't matter for diff)
    return np.frombuffer(raw.raw, dtype=np.uint8).reshape(
        raw.height, raw.width, 4
    )[:, :, :3]


# ──────────────────────────────────────────────────────────────────────────────
# Direction detection
# ──────────────────────────────────────────────────────────────────────────────

def _detect_direction(
    prev: np.ndarray,
    curr: np.ndarray,
    pixel_thresh: int,
    motion_thresh: int,
    cx: int,
    cy: int,
    debug: bool = False,
) -> str | None:
    """
    Returns compass direction the motion centroid is heading, or None if still.
    """
    diff = np.max(np.abs(curr.astype(np.int16) - prev.astype(np.int16)), axis=2)
    mask = diff > pixel_thresh

    n_changed = int(mask.sum())
    if debug:
        print(f"[fishing] changed_px={n_changed}  thresh={motion_thresh}", end="  ")

    if n_changed < motion_thresh:
        return None

    ys, xs = np.where(mask)
    centroid_x = float(xs.mean()) - cx
    centroid_y = float(ys.mean()) - cy   # positive = downward on screen

    # Dead-zone: centroid very close to centre
    if abs(centroid_x) < cx * 0.1 and abs(centroid_y) < cy * 0.1:
        return None

    # Proper range-based direction mapping
    # arctan2 convention: 0°=right(E), 90°=down(S), ±180°=left(W), -90°=up(N)
    a = float(np.degrees(np.arctan2(centroid_y, centroid_x)))

    if   -22.5 <= a <  22.5:  return "E"
    elif  22.5 <= a <  67.5:  return "SE"
    elif  67.5 <= a < 112.5:  return "S"
    elif 112.5 <= a < 157.5:  return "SW"
    elif a >= 157.5 or a < -157.5: return "W"
    elif -157.5 <= a < -112.5: return "NW"
    elif -112.5 <= a <  -67.5: return "N"
    else:                      return "NE"   # -67.5 <= a < -22.5


# ──────────────────────────────────────────────────────────────────────────────
# Bot class
# ──────────────────────────────────────────────────────────────────────────────

class Bot:
    """
    Required interface: __init__, start, stop, tick.
    tick() is called in a loop by the runner while active.
    """

    def __init__(self, args: dict):
        self.region_pct   = args.get("region_pct",   30)
        self.pixel_thresh = args.get("pixel_thresh",  25)
        self.motion_thresh= args.get("motion_thresh", 40)
        self.still_frames = args.get("still_frames",  8)
        self.fps          = args.get("fps",           20)
        self.debug        = args.get("debug",         False)

        self._kb          = KbController()
        self._mouse       = MouseController()
        self._running     = False

        self._held_keys: set[str] = set()
        self._reeling               = False
        self._still_count           = 0

        self._frame_interval = 1.0 / max(1, self.fps)
        self._stop_event = threading.Event()

        # mss instance kept open during run (opened in start())
        self._sct:    "mss.mss | None"    = None
        self._region: "dict | None"        = None
        self._cx     = 0
        self._cy     = 0
        self._prev_frame: np.ndarray | None = None

    # ── lifecycle ─────────────────────────────────────────────────────────────

    def start(self):
        import mss as _mss
        self._stop_event.clear()
        self._running     = True
        self._still_count = 0
        self._reeling     = False
        self._prev_frame  = None

        self._region, self._cx, self._cy = _get_center_region(self.region_pct)
        self._sct = _mss.mss()

        # --test-capture: save one frame then bail
        if self.debug or getattr(self, 'test_capture', False):
            print(
                f"[fishing] Capture region: {self._region}  "
                f"centre=({self._cx},{self._cy})"
            )
        if getattr(self, 'test_capture', False):
            from PIL import Image
            frame = _capture(self._sct, self._region)
            path = "/tmp/fishing_capture.png"
            Image.fromarray(frame[:, :, ::-1]).save(path)   # BGR->RGB
            print(f"[fishing] Screenshot saved to {path} — open it to verify the game is visible.")
            self._sct.close()
            self._sct = None

    def stop(self):
        """Signal the tick loop to stop. BotManager joins the thread before cleanup."""
        self._running = False
        self._stop_event.set()
        self._release_all()
        # Don't close _sct here — tick() may still be in a capture call.
        # BotManager.join() ensures the thread exits first.

    def tick(self):
        if self._stop_event.is_set() or self._sct is None:
            return

        t0 = time.monotonic()
        curr = _capture(self._sct, self._region)

        if self._prev_frame is None:
            self._prev_frame = curr
            time.sleep(self._frame_interval)
            return

        direction = _detect_direction(
            self._prev_frame, curr,
            self.pixel_thresh, self.motion_thresh,
            self._cx, self._cy,
            debug=self.debug,
        )
        self._prev_frame = curr

        if direction is not None:
            # Fish is pulling — counter it
            self._still_count = 0
            if self._reeling:
                self._stop_reel()
            self._set_counter_keys(direction)
            if self.debug:
                opp = _OPPOSITE[direction]
                print(f"[fishing] Fish→{direction}  Counter→{_DIR_KEYS[opp]}")
        else:
            # Bobber is still
            self._still_count += 1
            self._release_move_keys()
            if self._still_count >= self.still_frames and not self._reeling:
                self._start_reel()
                if self.debug:
                    print("[fishing] Reeling in…")

        elapsed = time.monotonic() - t0
        sleep_t = self._frame_interval - elapsed
        if sleep_t > 0:
            time.sleep(sleep_t)

    # ── input helpers ─────────────────────────────────────────────────────────

    def _set_counter_keys(self, fish_direction: str):
        opp   = _OPPOSITE[fish_direction]
        keys  = set(_DIR_KEYS[opp])
        # Release keys no longer needed
        for k in list(self._held_keys):
            if k not in keys:
                self._kb.release(k)
                self._held_keys.discard(k)
        # Press new keys
        for k in keys:
            if k not in self._held_keys:
                self._kb.press(k)
                self._held_keys.add(k)

    def _release_move_keys(self):
        for k in list(self._held_keys):
            try:
                self._kb.release(k)
            except Exception:
                pass
        self._held_keys.clear()

    def _start_reel(self):
        self._reeling = True
        self._mouse.press(Button.left)

    def _stop_reel(self):
        self._reeling = False
        self._mouse.release(Button.left)

    def _release_all(self):
        self._release_move_keys()
        if self._reeling:
            self._stop_reel()
