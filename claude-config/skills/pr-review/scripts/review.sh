#!/usr/bin/env bash
# Automated checks run as part of /pr-review
set -euo pipefail

echo "=== Linting (ruff) ==="
if command -v ruff &>/dev/null; then
  ruff check . --select=E,W,F,B,S --output-format=concise 2>&1 | head -40 || true
else
  echo "ruff not installed — skipping"
fi

echo ""
echo "=== Type check (mypy) ==="
if command -v mypy &>/dev/null; then
  mypy . --ignore-missing-imports --no-error-summary 2>&1 | tail -20 || true
else
  echo "mypy not installed — skipping"
fi

echo ""
echo "=== Secret scan (git) ==="
git log origin/main...HEAD --all -p \
  | grep -iE "(password|secret|token|api_key|credentials)\s*=" \
  | grep -v "get_secret\|#" || echo "No obvious secrets found"

echo ""
echo "=== Test coverage ==="
if command -v pytest &>/dev/null; then
  pytest --tb=no -q 2>&1 | tail -10 || true
else
  echo "pytest not installed — skipping"
fi
