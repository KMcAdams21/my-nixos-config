#!/usr/bin/env python3
"""
Game Bot Runner — minimal glue that loads a bot from bots/ and toggles it.

Usage:  game-bot <bot_name> [bot options]
        game-bot --list

Controls:
    F8      — toggle bot on/off
    Ctrl+C  — quit
"""

import sys, threading, importlib, argparse
from pathlib import Path
from typing import Optional

C = dict(reset="\033[0m", bold="\033[1m", green="\033[92m",
         yellow="\033[93m", red="\033[91m", cyan="\033[96m", dim="\033[2m")

BOTS_DIR = Path(__file__).parent / "bots"


def banner(name):
    print(f"\n{C['bold']}{C['cyan']}╔══════════════════════════════════╗")
    print(f"║       Game Bot Runner v1.0       ║")
    print(f"╚══════════════════════════════════╝{C['reset']}")
    print(f"  {C['dim']}bot:{C['reset']}  {C['bold']}{name}{C['reset']}")
    print(f"  {C['dim']}F8{C['reset']}   → toggle    {C['dim']}Ctrl+C{C['reset']} → quit\n")


def status(active):
    s = f"{C['green']}{C['bold']}● RUNNING{C['reset']} (F8 to pause)" if active \
        else f"{C['yellow']}{C['bold']}⏸ PAUSED{C['reset']}  (F8 to start)"
    print(f"\r  {s}  ", end="", flush=True)


class Runner:
    def __init__(self, mod, args):
        self.bot    = mod.Bot(args)
        self.active = False
        self._lock  = threading.Lock()
        self._t: Optional[threading.Thread] = None

    def toggle(self):
        with self._lock:
            if self.active:
                self.active = False
                self.bot.stop()
                if self._t:
                    self._t.join(timeout=2)
            else:
                self.active = True
                self.bot.start()
                self._t = threading.Thread(target=self._loop, daemon=True)
                self._t.start()

    def _loop(self):
        while self.active:
            try:
                self.bot.tick()
            except Exception as e:
                print(f"\n{C['red']}Bot error: {e}{C['reset']}")
                self.active = False

    def run(self):
        from pynput import keyboard as kb

        def on_press(key):
            if key == kb.Key.f8:
                self.toggle()
                status(self.active)

        status(self.active)
        with kb.Listener(on_press=on_press) as listener:
            try:
                listener.join()
            except KeyboardInterrupt:
                pass

        if self.active:
            self.toggle()
        print(f"\n{C['red']}Stopped.{C['reset']}\n")


def main():
    sys.path.insert(0, str(BOTS_DIR))

    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help", "--list"):
        print("\nAvailable bots:")
        for p in sorted(BOTS_DIR.glob("*.py")):
            if not p.name.startswith("_"):
                print(f"  {p.stem}")
        print("\nUsage: game-bot <bot_name> [options]\n")
        sys.exit(0)

    bot_name = sys.argv[1]
    rest = sys.argv[2:]

    try:
        mod = importlib.import_module(bot_name)
    except ModuleNotFoundError:
        print(f"{C['red']}Bot '{bot_name}' not found in {BOTS_DIR}/{C['reset']}")
        sys.exit(1)

    parser = argparse.ArgumentParser(prog=f"game-bot {bot_name}",
                                     description=mod.__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    if hasattr(mod, "add_args"):
        mod.add_args(parser)
    args = parser.parse_args(rest)

    banner(bot_name)
    Runner(mod, vars(args)).run()


if __name__ == "__main__":
    main()
