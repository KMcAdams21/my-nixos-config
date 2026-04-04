"""
movement_farmer — WASD circle bot
Traces an 8-step compass loop (N→NE→E→SE→S→SW→W→NW) so you return
to your start position each lap.

Options:
    --sneak       Hold Ctrl throughout (farms sneak XP)
    --step-ms N   Key hold duration per step in ms (default: 400)
"""

import time
from pynput.keyboard import Key, Controller

# 8-point compass — net displacement ≈ zero after one full lap
_CIRCLE = [
    ("w",),
    ("w", "d"),
    ("d",),
    ("s", "d"),
    ("s",),
    ("s", "a"),
    ("a",),
    ("w", "a"),
]

def add_args(parser):
    parser.add_argument("--sneak", action="store_true",
                        help="Hold Ctrl (sneak) the whole time")
    parser.add_argument("--step-ms", type=int, default=400, metavar="N",
                        help="Duration per directional step in ms (default: 400)")


class Bot:
    def __init__(self, args):
        self._kb      = Controller()
        self.sneak    = args.get("sneak", False)
        self.step_s   = args.get("step_ms", 400) / 1000.0
        self._running = False

    def start(self):
        self._running = True
        if self.sneak:
            self._kb.press(Key.ctrl)

    def stop(self):
        self._running = False
        for k in ("w", "a", "s", "d"):
            try: self._kb.release(k)
            except Exception: pass
        if self.sneak:
            try: self._kb.release(Key.ctrl)
            except Exception: pass

    def tick(self):
        """One full lap of the circle."""
        for step_keys in _CIRCLE:
            if not self._running:
                return
            for k in step_keys:
                self._kb.press(k)
            time.sleep(self.step_s)
            for k in step_keys:
                self._kb.release(k)
            time.sleep(0.05)
