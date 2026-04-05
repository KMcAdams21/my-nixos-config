#!/usr/bin/env python3
"""
game-bot-tray — System tray GUI for the game bot runner.

Select a bot from the tray menu, configure its options,
then press F8 to toggle it on/off. The CLI runner still
works independently alongside this.
"""

import sys
import threading
import importlib
import argparse
from pathlib import Path

from PyQt6.QtWidgets import QApplication, QSystemTrayIcon, QMenu, QActionGroup
from PyQt6.QtGui import QIcon, QPixmap, QPainter, QColor, QAction
from PyQt6.QtCore import Qt, pyqtSignal, QObject

BOTS_DIR = Path(__file__).parent / "bots"
sys.path.insert(0, str(BOTS_DIR))


# ── Icon helpers (must be called after QApplication exists) ───────────────────

def make_icon(color: str, size: int = 20) -> QIcon:
    px = QPixmap(size, size)
    px.fill(Qt.GlobalColor.transparent)
    p = QPainter(px)
    p.setRenderHint(QPainter.RenderHint.Antialiasing)
    p.setBrush(QColor(color))
    p.setPen(Qt.PenStyle.NoPen)
    p.drawEllipse(1, 1, size - 2, size - 2)
    p.end()
    return QIcon(px)


# ── Bot discovery ─────────────────────────────────────────────────────────────

def discover_bots() -> list[str]:
    return sorted(
        p.stem for p in BOTS_DIR.glob("*.py")
        if not p.name.startswith("_")
    )


def get_bool_flags(bot_name: str) -> list[tuple[str, str, str]]:
    """Return (dest, flag, help) for each boolean flag the bot declares."""
    try:
        mod = importlib.import_module(bot_name)
    except Exception:
        return []
    if not hasattr(mod, "add_args"):
        return []
    parser = argparse.ArgumentParser()
    mod.add_args(parser)
    return [
        (a.dest, a.option_strings[0], a.help or "")
        for a in parser._actions
        if a.option_strings and getattr(a, "const", None) is True
    ]


# ── Bot runner (background thread) ────────────────────────────────────────────

class Signals(QObject):
    status_changed = pyqtSignal(bool)


class BotManager:
    def __init__(self, signals: Signals):
        self.signals   = signals
        self.active    = False
        self._bot      = None
        self._thread: threading.Thread | None = None
        self._lock     = threading.Lock()
        self.bot_name: str | None = None
        self.bot_args: dict       = {}

    def select(self, bot_name: str, args: dict):
        """Swap to a new bot; restarts it if currently running."""
        was_running = self.active
        if was_running:
            self._stop()
        self.bot_name = bot_name
        self.bot_args = args
        if was_running:
            self._start()

    def toggle(self):
        with self._lock:
            if self.active:
                self._stop()
            else:
                self._start()
        self.signals.status_changed.emit(self.active)

    # ── private ───────────────────────────────────────────────────────────────

    def _start(self):
        if not self.bot_name:
            return
        self.active = True
        try:
            mod = importlib.import_module(self.bot_name)
            self._bot = mod.Bot(self.bot_args)
            self._bot.start()
        except Exception as e:
            print(f"Bot load error: {e}")
            self.active = False
            return
        self._thread = threading.Thread(target=self._loop, daemon=True)
        self._thread.start()

    def _stop(self):
        self.active = False
        if self._bot:
            try:
                self._bot.stop()
            except Exception:
                pass
        if self._thread:
            self._thread.join(timeout=2)
            self._thread = None

    def _loop(self):
        while self.active:
            try:
                self._bot.tick()
            except Exception as e:
                print(f"Bot error: {e}")
                self.active = False
                break


# ── Tray app ──────────────────────────────────────────────────────────────────

class TrayApp:
    def __init__(self, app: QApplication):
        self.app     = app
        self.signals = Signals()
        self.manager = BotManager(self.signals)

        self._selected_bot: str | None = None
        self._bot_flags: dict          = {}
        self._flag_actions: list[QAction] = []
        self._bot_actions:  dict[str, QAction] = {}

        # Icons created after QApplication exists
        self._icon_paused  = make_icon("#777777")
        self._icon_running = make_icon("#44cc44")

        # Build tray icon
        self.tray = QSystemTrayIcon()
        self.tray.setIcon(self._icon_paused)
        self.tray.setToolTip("Game Bot — PAUSED")
        self.tray.activated.connect(self._on_activated)

        self._build_menu()
        self.tray.show()

        self.signals.status_changed.connect(self._on_status_changed)
        self._start_hotkey_listener()

    # ── Menu ──────────────────────────────────────────────────────────────────

    def _build_menu(self):
        self.menu = QMenu()

        # Header
        hdr = self.menu.addAction("🎮 Game Bot Runner")
        hdr.setEnabled(False)
        self.menu.addSeparator()

        # Bot radio buttons
        bots = discover_bots()
        group = QActionGroup(self.menu)
        group.setExclusive(True)
        for name in bots:
            act = QAction(name, self.menu, checkable=True)
            act.setActionGroup(group)
            act.triggered.connect(lambda _, n=name: self._select_bot(n))
            self.menu.addAction(act)
            self._bot_actions[name] = act

        # Flags will be inserted between these two separators
        self.menu.addSeparator()
        self._flags_insert_point = self.menu.addSeparator()  # flags go before this

        # Status + hint
        self._status_act = self.menu.addAction("⏸  PAUSED")
        self._status_act.setEnabled(False)
        hint = self.menu.addAction("Press F8 to toggle")
        hint.setEnabled(False)

        self.menu.addSeparator()
        self.menu.addAction("Quit", self.app.quit)

        self.tray.setContextMenu(self.menu)

        # Select first bot by default
        if bots:
            self._bot_actions[bots[0]].setChecked(True)
            self._select_bot(bots[0])

    def _rebuild_flags(self):
        # Remove old flag actions from menu
        for act in self._flag_actions:
            self.menu.removeAction(act)
        self._flag_actions.clear()

        if not self._selected_bot:
            return

        for dest, flag, help_text in get_bool_flags(self._selected_bot):
            label = f"{flag}" + (f"  —  {help_text}" if help_text else "")
            act = QAction(label, self.menu, checkable=True)
            act.setChecked(self._bot_flags.get(dest, False))
            act.triggered.connect(lambda checked, d=dest: self._set_flag(d, checked))
            # Insert before the closing separator
            self.menu.insertAction(self._flags_insert_point, act)
            self._flag_actions.append(act)

    # ── Slots ─────────────────────────────────────────────────────────────────

    def _on_activated(self, reason):
        # Left-click shows menu (right-click already does by default on most DEs)
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            self.tray.contextMenu().popup(self.tray.geometry().bottomLeft())

    def _select_bot(self, name: str):
        self._selected_bot = name
        self._bot_flags    = {}
        self._rebuild_flags()
        self.manager.select(name, {})

    def _set_flag(self, dest: str, value: bool):
        self._bot_flags[dest] = value
        self.manager.select(self._selected_bot, dict(self._bot_flags))

    def _on_status_changed(self, active: bool):
        if active:
            self.tray.setIcon(self._icon_running)
            self.tray.setToolTip("Game Bot — RUNNING")
            self._status_act.setText("●  RUNNING")
        else:
            self.tray.setIcon(self._icon_paused)
            self.tray.setToolTip("Game Bot — PAUSED")
            self._status_act.setText("⏸  PAUSED")

    # ── F8 global hotkey ──────────────────────────────────────────────────────

    def _start_hotkey_listener(self):
        def listen():
            try:
                from pynput import keyboard as kb
                with kb.Listener(on_press=self._on_key) as l:
                    l.join()
            except Exception as e:
                print(f"Hotkey listener error: {e}")

        threading.Thread(target=listen, daemon=True).start()

    def _on_key(self, key):
        from pynput import keyboard as kb
        if key == kb.Key.f8:
            self.manager.toggle()


# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    app = QApplication(sys.argv)
    app.setQuitOnLastWindowClosed(False)  # stay alive when no windows open

    if not QSystemTrayIcon.isSystemTrayAvailable():
        print("No system tray available on this desktop.")
        sys.exit(1)

    _tray = TrayApp(app)
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
