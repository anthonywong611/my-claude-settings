#!/usr/bin/env bash
# Hook: fires on Claude Code notifications (e.g. long task completed)
# Customize: send a desktop notification, Slack message, or sound

set -euo pipefail

MSG="${CLAUDE_NOTIFICATION_MESSAGE:-Claude Code finished a task}"

# macOS
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$MSG\" with title \"Claude Code\""
  exit 0
fi

# Linux (notify-send)
if command -v notify-send &>/dev/null; then
  notify-send "Claude Code" "$MSG"
  exit 0
fi

# Fallback: print to terminal
echo "[Claude Code] $MSG"
