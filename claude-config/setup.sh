#!/usr/bin/env bash
# setup.sh — Install claude-config by symlinking into ~/.claude
# Cross-platform: macOS + Linux
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

echo "=== Claude Code Config Installer ==="
echo "Repo:   $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# --- Backup existing ~/.claude if it exists and is not already our symlink ---
if [ -e "$CLAUDE_DIR" ] && [ ! -L "$CLAUDE_DIR" ]; then
  BACKUP="${CLAUDE_DIR}.bak.$TIMESTAMP"
  echo "Backing up existing ~/.claude → $BACKUP"
  cp -r "$CLAUDE_DIR" "$BACKUP"
fi

mkdir -p "$CLAUDE_DIR"

# --- Symlink top-level files ---
for file in CLAUDE.md settings.json; do
  TARGET="$CLAUDE_DIR/$file"
  [ -L "$TARGET" ] && rm "$TARGET"
  [ -e "$TARGET" ] && mv "$TARGET" "${TARGET}.bak.$TIMESTAMP"
  ln -sf "$REPO_DIR/$file" "$TARGET"
  echo "Linked  $file"
done

# --- Symlink directories ---
for dir in skills agents hooks rules mcp includes; do
  TARGET="$CLAUDE_DIR/$dir"
  [ -L "$TARGET" ] && rm "$TARGET"
  if [ -e "$TARGET" ]; then
    mv "$TARGET" "${TARGET}.bak.$TIMESTAMP"
    echo "Moved existing $dir → ${dir}.bak.$TIMESTAMP"
  fi
  ln -sf "$REPO_DIR/$dir" "$TARGET"
  echo "Linked  $dir/"
done

# --- settings.local.json: copy template if not already present (never symlink — machine-specific) ---
LOCAL_SETTINGS="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$LOCAL_SETTINGS" ]; then
  cp "$REPO_DIR/settings.local.example.json" "$LOCAL_SETTINGS"
  echo ""
  echo "Created settings.local.json — EDIT THIS FILE with your real credentials:"
  echo "  $LOCAL_SETTINGS"
else
  echo "Kept existing settings.local.json (not overwritten)"
fi

# --- Git hook: pre-commit secret scan ---
GIT_HOOKS_DIR="$REPO_DIR/.git/hooks"
if [ -d "$GIT_HOOKS_DIR" ]; then
  ln -sf "$REPO_DIR/hooks/pre-commit-secrets.sh" "$GIT_HOOKS_DIR/pre-commit"
  echo "Linked  git pre-commit hook → hooks/pre-commit-secrets.sh"
fi

# --- Verify MCP servers are installed ---
echo ""
echo "=== Checking MCP server dependencies ==="
if ! command -v npx &>/dev/null; then
  echo "WARNING: npx not found. Install Node.js to use MCP servers."
else
  echo "npx found."
fi

echo ""
echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  1. Edit $LOCAL_SETTINGS with your credentials"
echo "  2. Run: claude  (to verify config loads)"
echo "  3. In Claude Code, type /beam-debug to test a skill"
