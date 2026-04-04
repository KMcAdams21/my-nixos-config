#!/usr/bin/env bash
# game-bot — runner for shell-based game bots
# Usage:  game-bot <bot_name> [options passed to bot]
#
# Start/stop:
#   game-bot <name> [opts]   — runs the bot in the foreground
#   Ctrl+C                   — stops it cleanly
#
# The bot stays running in a loop until interrupted.
# Run it in a terminal or floating window you can Alt+F4.

set -euo pipefail

BOTS_DIR="$(dirname "$(realpath "$0")")/bots"
BOT_NAME="${1:-}"

# ── Help / list bots ──────────────────────────────────────────────────────────
if [[ -z "$BOT_NAME" || "$BOT_NAME" == "--help" || "$BOT_NAME" == "-h" ]]; then
  echo ""
  echo "  ╔══════════════════════════════════╗"
  echo "  ║       Game Bot Runner v2.0       ║"
  echo "  ╚══════════════════════════════════╝"
  echo ""
  echo "  Usage:  game-bot <bot_name> [options]"
  echo ""
  echo "  Available bots:"
  for f in "$BOTS_DIR"/*.sh; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f" .sh)"
    # Print name + first comment line as description
    desc="$(grep -m1 '^# Description:' "$f" | sed 's/# Description: *//' || true)"
    printf "    %-20s %s\n" "$name" "$desc"
  done
  echo ""
  exit 0
fi

shift  # remaining args passed to the bot script

BOT_SCRIPT="$BOTS_DIR/${BOT_NAME}.sh"

if [[ ! -f "$BOT_SCRIPT" ]]; then
  echo "Error: bot '${BOT_NAME}' not found in ${BOTS_DIR}/"
  exit 1
fi

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║       Game Bot Runner v2.0       ║"
echo "  ╚══════════════════════════════════╝"
echo "  Bot:  ${BOT_NAME}"
echo "  Ctrl+C to stop"
echo ""

# ── PID tracking: clean up on exit ───────────────────────────────────────────
_CHILD_PID=""

cleanup() {
  echo ""
  echo "  Stopping bot..."
  if [[ -n "$_CHILD_PID" ]] && kill -0 "$_CHILD_PID" 2>/dev/null; then
    kill "$_CHILD_PID" 2>/dev/null || true
    wait "$_CHILD_PID" 2>/dev/null || true
  fi
  # Release any stuck keys by sending keyup for common movement keys
  xdotool keyup w a s d ctrl 2>/dev/null || true
  echo "  Done."
}
trap cleanup EXIT INT TERM

# ── Run bot in background, wait on it ────────────────────────────────────────
bash "$BOT_SCRIPT" "$@" &
_CHILD_PID=$!
echo "  ● RUNNING  (pid: ${_CHILD_PID})"

wait "$_CHILD_PID"
