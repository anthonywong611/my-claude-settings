# Git Rules

## Conventional commits
Format: `type(scope): short imperative description`

Types:
- `feat`: new feature or capability
- `fix`: bug fix
- `refactor`: code change without behaviour change
- `chore`: build, deps, tooling
- `docs`: documentation only
- `test`: test additions or changes
- `perf`: performance improvement
- `ci`: CI/CD pipeline changes

Examples:
- `feat(beam-debug): add setup() credential fetch pattern`
- `fix(bq-writer): pass schema explicitly to WriteToBigQuery`
- `ci(ado): add secret scan step to PR validation pipeline`

## Branching
- `main` — production-ready, protected
- `feat/<ticket-id>-short-description`
- `fix/<ticket-id>-short-description`
- `chore/<description>`

## Pull requests
- Title follows conventional commit format
- Description includes: what changed, why, how tested, link to ADO ticket
- Minimum one approval before merge
- Squash merge to main — keep history clean
