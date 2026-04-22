# claude-config

Personal Claude Code configuration — skills, agents, rules, hooks, and MCP wiring.
Managed as a dotfiles repo and symlinked into `~/.claude/`.

## Quick start

```bash
git clone git@github.com:<YOU>/claude-config.git ~/claude-config
cd ~/claude-config
bash setup.sh
# Edit ~/.claude/settings.local.json with your credentials
claude   # verify it loads
```

## Structure

```
claude-config/
├── CLAUDE.md                         # Global always-on instructions
├── settings.json                     # Permissions, hooks, MCP wiring
├── settings.local.example.json       # Template for gitignored local secrets
│
├── skills/                           # Slash commands + auto-triggered workflows
│   ├── beam-debug/SKILL.md           # /beam-debug  — debug pipeline failures
│   ├── gcp-dataflow/SKILL.md         # /gcp-dataflow — job ops and log inspection
│   ├── pr-review/SKILL.md            # /pr-review   — structured code review
│   │   └── scripts/review.sh         #   bundled automation
│   ├── git-flow/SKILL.md             # /git-flow    — branch/commit/PR workflow
│   └── scaffold-pipeline/SKILL.md   # /scaffold-pipeline — new pipeline generator
│
├── agents/                           # Specialist subagents (spawned via Task tool)
│   ├── pipeline-debugger.md          # Beam/Dataflow credential + logic expert
│   ├── data-engineer.md              # BQ, GCS, schema design
│   ├── security-reviewer.md          # IAM, secret scanning, vulnerability review
│   └── devops-specialist.md          # Azure DevOps ↔ GCP CI/CD bridging
│
├── hooks/                            # Shell scripts fired by Claude Code events
│   ├── pre-commit-secrets.sh         # Blocks commits containing secrets
│   ├── post-tool-format.sh           # Auto-formats Python after edits
│   └── on-notification.sh            # Desktop/terminal notification on task complete
│
├── rules/                            # Reference standards (loaded by CLAUDE.md)
│   ├── python.md                     # Type hints, error handling, imports, testing
│   ├── beam.md                       # DoFn lifecycle, serialisation, BQ writes
│   ├── gcp.md                        # Auth, Secret Manager, BigQuery, GCS, IAM
│   └── git.md                        # Conventional commits, branching, PRs
│
├── mcp/                              # MCP server documentation and reference configs
│   ├── github.json                   # GitHub MCP — PRs, issues, code search
│   ├── azure-devops.json             # ADO MCP — work items, pipelines
│   └── README.md                     # Setup instructions for each server
│
├── includes/                         # Shared reference docs (referenced in skills + CLAUDE.md)
│   ├── credential-patterns.md        # The DoFn setup() pattern for GCP Secret Manager
│   ├── beam-patterns.md              # Canonical pipeline structure, Excel reading, options
│   └── gcp-standards.md             # Naming conventions, IAM matrix, BQ conventions
│
├── templates/                        # Scaffolds for new projects
│   └── project/.claude/             # Copy to <project>/.claude/ and customise
│       ├── CLAUDE.md                 # Project-specific context
│       ├── settings.json             # Project-level permission overrides
│       ├── skills/example-skill/     # Starter project skill
│       ├── agents/domain-expert.md   # Starter project agent
│       └── commands/deploy.md        # Starter deploy command
│
└── setup.sh                          # Installer: symlinks everything into ~/.claude/
```

## Adding a new skill

```bash
mkdir -p skills/my-skill
cat > skills/my-skill/SKILL.md << 'MD'
---
name: my-skill
description: What this skill does and when to trigger it automatically.
argument-hint: "[what to pass after /my-skill]"
allowed-tools: [Bash, Read]
---
Instructions for Claude go here. Use $ARGUMENTS for slash-command input.
MD

git add skills/my-skill/SKILL.md
git commit -m "feat(skills): add my-skill"
git push
# Symlink already in place — skill is immediately available in Claude Code
```

## Adding a new agent

```bash
cat > agents/my-agent.md << 'MD'
---
name: my-agent
description: When to spawn this agent (Claude's Task tool uses this).
model: claude-sonnet-4-20250514
allowed-tools: [Bash, Read]
---
Agent persona and instructions.
MD

git add agents/my-agent.md
git commit -m "feat(agents): add my-agent"
```

## Syncing across machines

```bash
# On the new machine
git clone git@github.com:<YOU>/claude-config.git ~/claude-config
bash ~/claude-config/setup.sh

# Pulling updates on an existing machine
cd ~/claude-config && git pull
# Symlinks are already in place — no re-run needed
```

## Credentials

`settings.local.json` is gitignored. It holds real values for the env vars referenced
in `settings.json` and `settings.local.example.json`.

Required for MCP servers:
- `GITHUB_PAT` — GitHub Personal Access Token (`repo`, `pull_requests` scopes)
- `AZURE_DEVOPS_ORG_URL` — e.g. `https://dev.azure.com/your-org`
- `AZURE_DEVOPS_PAT` — ADO Personal Access Token
- `GCP_PROJECT_ID` — default GCP project
