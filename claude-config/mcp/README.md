# MCP Server Configurations

These JSON files document the MCP servers wired into `settings.json`.
Credentials are loaded from `settings.local.json` (gitignored) via env var substitution.

## GitHub
- Server package: `@modelcontextprotocol/server-github`
- Required env: `GITHUB_PAT` — Personal Access Token with `repo`, `pull_requests` scopes
- Capabilities: read/write issues, PRs, files, search code, create branches

## Azure DevOps
- Server package: `@tiberriver256/mcp-server-azure-devops`
- Required env: `AZURE_DEVOPS_ORG_URL`, `AZURE_DEVOPS_PAT`
- PAT scopes needed: `Work Items (Read & Write)`, `Build (Read & Execute)`, `Code (Read)`
- Capabilities: read/create work items, trigger pipelines, read pipeline runs

## Adding a new MCP server
1. Add the server entry to `settings.json` under `mcpServers`
2. Add required env vars to `settings.local.example.json`
3. Document it in this README
4. Never commit real credentials — env vars only
