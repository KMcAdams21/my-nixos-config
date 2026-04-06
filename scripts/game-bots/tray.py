#!/usr/bin/env python3
"""
game-bot-tray — System tray GUI for the game bot runner.

Select a bot from the tray menu, open ⚙ Settings to configure its
parameters, then press F8 to toggle it on/off. The CLI runner still
works independently alongside this.
"""

import sys
import threading
import importlib
import argparse
from pathlib import Path

from PyQt6.QtWidgets import (
    QApplication, QSystemTrayIcon, QMenu,
    QDialog, QDialogButtonBox, QFormLayout, QVBoxLayout,
    QSpinBox, QDoubleSpinBox, QCheckBox, QLineEdit,
)
from PyQt6.QtGui import QIcon, QPixmap, QPainter, QColor, QAction, QActionGroup
from PyQt6.QtCore import Qt, pyqtSignal, QObject

BOTS_DIR = Path(__file__).parent / "bots"
sys.path.insert(0, str(BOTS_DIR))


# ── Icon helpers ───────────────────────────────────────────────────────────────

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


# ── Bot discovery ──────────────────────────────────────────────────────────────

def discover_bots() -> list[str]:
    return sorted(
        p.stem for p in BOTS_DIR.glob("*.py")
        if not p.name.startswith("_")
    )


def get_all_args(bot_name: str) -> list[dict]:
    """Return every declared arg with its type, default, and help text."""
    try:
        mod = importlib.import_module(bot_name)
    except Exception:
        return []
    if not hasattr(mod, "add_args"):
        return []
    parser = argparse.ArgumentParser()
    mod.add_args(parser)
    result = []
    for action in parser._actions:
        if not action.option_strings or action.dest == "help":
            continue
        is_bool = getattr(action, "const", None) is True
        arg_type = (
            "bool"  if is_bool else
            "int"   if action.type is int else
            "float" if action.type is float else
            "str"
        )
        result.append({
            "dest":    action.dest,
            "flag":    action.option_strings[0],
            "help":    action.help or "",
            "type":    arg_type,
            "default": action.default,
        })
    return result


# ── Settings dialog ────────────────────────────────────────────────────────────

class SettingsDialog(QDialog):
    """
    Auto-builds a form from a bot's declared argparse args.
    Bool   → QCheckBox
    Int    → QSpinBox
    Float  → QDoubleSpinBox
    Str    → QLineEdit
    """

    def __init__(self, bot_name: str, current_values: dict, parent=None):
        super().__init__(parent)
        self.setWindowTitle(f"⚙  {bot_name} — Settings")
        self.setMinimumWidth(400)

        args = get_all_args(bot_name)
        self._widgets: dict[str, tuple] = {}

        form = QFormLayout()
        form.setRowWrapPolicy(QFormLayout.RowWrapPolicy.WrapLongRows)
        form.setLabelAlignment(Qt.AlignmentFlag.AlignRight)

        for arg in args:
            dest    = arg["dest"]
            current = current_values.get(dest, arg["default"])
            tip     = arg["help"]

            if arg["type"] == "bool":
                w = QCheckBox()
                w.setChecked(bool(current))
            elif arg["type"] == "int":
                w = QSpinBox()
                w.setRange(0, 99_999)
                w.setValue(int(current) if current is not None else 0)
            elif arg["type"] == "float":
                w = QDoubleSpinBox()
                w.setRange(0.0, 99_999.0)
                w.setDecimals(2)
                w.setValue(float(current) if current is not None else 0.0)
            else:
                w = QLineEdit(str(current or ""))

            w.setToolTip(tip)
            form.addRow(arg["flag"], w)
            self._widgets[dest] = (w, arg["type"])

        btns = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok |
            QDialogButtonBox.StandardButton.Cancel
        )
        btns.accepted.connect(self.accept)
        btns.rejected.connect(self.reject)

        layout = QVBoxLayout()
        layout.addLayout(form)
        layout.addWidget(btns)
        self.setLayout(layout)

    def get_values(self) -> dict:
        result = {}
        for dest, (w, type_name) in self._widgets.items():
            if   type_name == "bool":  result[dest] = w.isChecked()
            elif type_name == "int":   result[dest] = w.value()
            elif type_name == "float": result[dest] = w.value()
            else:                      result[dest] = w.text()
        return result


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

        self._selected_bot: str | None     = None
        self._bot_args:     dict           = {}          # current settings
        self._bot_actions:  dict[str, QAction] = {}

        self._icon_paused  = make_icon("#777777")
        self._icon_running = make_icon("#44cc44")

        self.tray = QSystemTrayIcon()
        self.tray.setIcon(self._icon_paused)
        self.tray.setToolTip("Game Bot — PAUSED")
        self.tray.activated.connect(self._on_activated)

        self._build_menu()
        self.tray.show()
        print("[game-bot] Tray icon shown — check the hidden icons '^' arrow in KDE if you don't see it")

        self.tray.showMessage(
            "Game Bot Ready",
            "Right-click the tray icon to select a bot and open Settings.",
            QSystemTrayIcon.MessageIcon.Information,
            4000,
        )

        self.signals.status_changed.connect(self._on_status_changed)
        self._start_hotkey_listener()

    # ── Menu ──────────────────────────────────────────────────────────────────

    def _build_menu(self):
        self.menu = QMenu()

        hdr = self.menu.addAction("🎮 Game Bot Runner")
        hdr.setEnabled(False)
        self.menu.addSeparator()

        # Bot selection (radio)
        bots  = discover_bots()
        group = QActionGroup(self.menu)
        group.setExclusive(True)
        for name in bots:
            act = QAction(name, self.menu, checkable=True)
            act.setActionGroup(group)
            act.triggered.connect(lambda _, n=name: self._select_bot(n))
            self.menu.addAction(act)
            self._bot_actions[name] = act

        self.menu.addSeparator()

        # Settings button — opens SettingsDialog for the selected bot
        self._settings_act = self.menu.addAction("⚙  Settings…")
        self._settings_act.triggered.connect(self._open_settings)
        self._settings_act.setEnabled(False)  # enabled once a bot is selected

        self.menu.addSeparator()

        self._status_act = self.menu.addAction("⏸  PAUSED")
        self._status_act.setEnabled(False)
        hint = self.menu.addAction("Press F8 to toggle")
        hint.setEnabled(False)

        self.menu.addSeparator()
        self.menu.addAction("Quit", self.app.quit)

        self.tray.setContextMenu(self.menu)

        if bots:
            self._bot_actions[bots[0]].setChecked(True)
            self._select_bot(bots[0])

    # ── Slots ─────────────────────────────────────────────────────────────────

    def _on_activated(self, reason):
        # Left-click: toggle bot. Right-click: KDE shows context menu natively.
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            self.manager.toggle()

    def _select_bot(self, name: str):
        self._selected_bot = name
        # Seed _bot_args with the bot's declared defaults
        self._bot_args = {
            a["dest"]: a["default"]
            for a in get_all_args(name)
        }
        self._settings_act.setEnabled(True)
        self._settings_act.setText(f"⚙  Settings…  ({name})")
        self.manager.select(name, dict(self._bot_args))

    def _open_settings(self):
        if not self._selected_bot:
            return
        dlg = SettingsDialog(self._selected_bot, self._bot_args)
        if dlg.exec() == QDialog.DialogCode.Accepted:
            self._bot_args = dlg.get_values()
            self.manager.select(self._selected_bot, dict(self._bot_args))

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
    import signal
    from PyQt6.QtCore import QTimer

    print("[game-bot] Starting tray app...")
    app = QApplication(sys.argv)
    app.setQuitOnLastWindowClosed(False)

    signal.signal(signal.SIGINT, lambda *_: app.quit())
    sigint_timer = QTimer()
    sigint_timer.start(500)
    sigint_timer.timeout.connect(lambda: None)

    print(f"[game-bot] System tray available: {QSystemTrayIcon.isSystemTrayAvailable()}")
    if not QSystemTrayIcon.isSystemTrayAvailable():
        print("[game-bot] ERROR: No system tray available.")
        sys.exit(1)

    _tray = TrayApp(app)
    print("[game-bot] Running. Ctrl+C to quit.")
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
