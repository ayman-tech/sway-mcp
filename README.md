# Sway MCP Server

Connect an MCP-compatible AI agent to your hosted Sway account. The server runs locally over stdio and sends authenticated task requests to `https://api.sway.aymanai.com`.

## Available tools

- `list_tasks` — list active tasks
- `get_task_groups` — group tasks into Overdue, Today, Next 7 Days, and Later
- `add_task` — create a timed, all-day, or untimed task
- `complete_task` — mark a task complete

## Requirements

- A Sway account at <https://sway.aymanai.com>
- A personal API key from **Settings → Sway API Key**
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- OpenClaw with MCP support

The API key grants access to your Sway tasks. Do not share it, commit it, or place it in this folder.

## Install for OpenClaw

Keep this folder in a permanent location because OpenClaw launches the MCP server from it. Then run:

```bash
chmod +x install-openclaw.sh uninstall-openclaw.sh
./install-openclaw.sh
```

The installer:

1. Prompts for the API key without displaying it.
2. Validates the key against the hosted Sway API.
3. Registers this folder's absolute path with OpenClaw.
4. Probes the MCP server.

If a registration named `sway` already exists, the installer asks before replacing it. Start a new OpenClaw agent session after installation.

Verify manually with:

```bash
openclaw mcp status --verbose
openclaw mcp doctor sway --probe
openclaw mcp tools sway
```

## Uninstall from OpenClaw

```bash
./uninstall-openclaw.sh
```

This removes the OpenClaw registration and its configured key. It does not delete the local folder, the Sway account, or any tasks. You can also revoke the key from Sway Settings.

## Manual MCP configuration

Other MCP clients can launch the server with:

```json
{
  "mcpServers": {
    "sway": {
      "command": "uv",
      "args": [
        "run",
        "--project",
        "/absolute/path/to/sway-mcp",
        "sway-mcp"
      ],
      "env": {
        "SWAY_API_URL": "https://api.sway.aymanai.com",
        "SWAY_API_KEY": "sway_your_personal_key"
      }
    }
  }
}
```

Prefer the client's secret store or environment-variable references when available. The exact configuration location varies by MCP client.

## Troubleshooting

- `SWAY_API_KEY is required`: generate a key in Sway Settings and reinstall the registration.
- `401 Unauthorized`: the key is invalid or was regenerated; rerun the installer with the current key.
- Connection errors: verify <https://api.sway.aymanai.com/health> is reachable.
- Tools do not appear: restart the OpenClaw Gateway or begin a new agent session.
