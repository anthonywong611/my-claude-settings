---
name: git-flow
description: >
  Git workflow operations: create branches, commit with conventional format, open PRs,
  tag releases. Use when user asks to commit, branch, or open a pull request.
argument-hint: "[describe what you want to commit/branch/PR]"
allowed-tools: [Bash]
disable-model-invocation: false
---

You are managing git workflow. Always check current state first.

! git status --short
! git branch --show-current

## Conventional commit format
`type(scope): description`

Types: `feat` `fix` `refactor` `chore` `docs` `test` `perf` `ci`

Examples:
- `feat(pipeline): add Secret Manager credential propagation to DoFns`
- `fix(bq-writer): declare schema explicitly to avoid auto-detect`
- `chore(deps): bump apache-beam to 2.55.0`

## Requested operation: $ARGUMENTS

Follow these steps:
1. Show `git diff --staged` (or `git diff HEAD`) to confirm what is changing
2. Propose a conventional commit message
3. Ask for confirmation before committing
4. If opening a PR, use `gh pr create` with a description linking to the relevant ADO ticket
