#!/usr/bin/env bash
# Hook: blocks commits that contain likely secrets
# Wire up: git config core.hooksPath ~/.claude/hooks  (or use lefthook/husky)

set -euo pipefail

PATTERNS=(
  "password\s*="
  "secret\s*="
  "api_key\s*="
  "PRIVATE KEY"
  "BEGIN RSA"
  "ghp_[A-Za-z0-9]{36}"      # GitHub PAT
  "AIza[A-Za-z0-9_-]{35}"    # GCP API key
)

STAGED=$(git diff --cached --name-only)
FOUND=0

for f in $STAGED; do
  [ -f "$f" ] || continue
  for p in "${PATTERNS[@]}"; do
    if grep -qiE "$p" "$f" 2>/dev/null; then
      echo "SECRET SCAN FAILED: '$p' found in $f"
      FOUND=1
    fi
  done
done

if [ $FOUND -ne 0 ]; then
  echo ""
  echo "Remove secrets before committing. Use GCP Secret Manager via get_secret()."
  exit 1
fi

echo "Secret scan passed."
