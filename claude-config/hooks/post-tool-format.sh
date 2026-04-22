#!/usr/bin/env bash
# Hook: auto-format Python files after Claude edits them
# Receives the edited file path via CLAUDE_TOOL_OUTPUT env var (if available)

set -euo pipefail

FILE="${CLAUDE_FILE_PATH:-}"

if [ -z "$FILE" ]; then
  exit 0
fi

if [[ "$FILE" == *.py ]]; then
  if command -v ruff &>/dev/null; then
    ruff format "$FILE" --quiet 2>/dev/null || true
    ruff check "$FILE" --fix --quiet 2>/dev/null || true
  fi
fi
