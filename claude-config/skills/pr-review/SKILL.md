---
name: pr-review
description: >
  Review a pull request for code quality, security, and data engineering standards.
  Use when user asks to review a PR, check a diff, or validate changes before merge.
argument-hint: "[PR number or branch name]"
allowed-tools: [Bash, Read, Grep]
---

You are conducting a structured PR review aligned to team standards.

## Step 1 — Get the diff

! git diff origin/main...HEAD --stat

If a PR number was provided ($ARGUMENTS), fetch via GitHub MCP or:
```bash
gh pr diff $ARGUMENTS
```

## Step 2 — Run automated checks

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/review.sh
```

## Step 3 — Review checklist

Work through each category. Report findings as: **Critical** / **Warning** / **Suggestion**.

### Security
- [ ] No secrets, tokens, or credentials in code or comments
- [ ] No `os.environ` for sensitive values — must use `get_secret()`
- [ ] No SQL string interpolation (parameterised queries only)
- [ ] No `eval()` or `exec()` on external input

### Data integrity
- [ ] BigQuery schemas declared explicitly (no auto-detect)
- [ ] Null handling is explicit — no silent drops
- [ ] GCS paths validated before use
- [ ] Idempotency: re-running the pipeline produces the same result

### Beam / Dataflow
- [ ] DoFns are serializable (no DB connections at class level)
- [ ] Secrets fetched in `setup()`, not `__init__()` or `process()`
- [ ] PTransforms are named descriptively
- [ ] Side inputs are bounded

### General
- [ ] Type hints on all function signatures
- [ ] No bare `except:` — catch specific exceptions
- [ ] Tests cover the changed logic
- [ ] Conventional commit message format

## Step 4 — Output

Group findings by severity. For each Critical/Warning, include:
1. File + line number
2. What the problem is
3. The minimal fix
