---
name: geo-mcp-setup
description: Use this skill when the user wants to configure QGIS MCP, set up PostGIS MCP, add geospatial MCP servers to their config, or says "setup qgis mcp", "configure postgis", "add geo mcp".
version: 1.0.0
---

# Geo MCP Setup

Configure QGIS and PostGIS MCP servers for Claude Code, OpenCode, and Gemini CLI.

## Configuration Formats

### Claude Code (`~/.claude/settings.json`)

```json
{
  "mcpServers": {
    "qgis": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/qgis_mcp/src/qgis_mcp",
        "run",
        "qgis_mcp_server.py"
      ]
    },
    "postgis": {
      "command": "mcp-server-postgres",
      "args": [
        "postgresql://user:password@127.0.0.1:5433/dbname"
      ]
    }
  }
}
```

### OpenCode (`~/.config/opencode/opencode.json`)

```json
{
  "mcp": {
    "qgis": {
      "type": "local",
      "command": [
        "uv",
        "run",
        "--directory",
        "/path/to/qgis_mcp/src/qgis_mcp",
        "qgis_mcp_server.py"
      ]
    },
    "postgis": {
      "type": "local",
      "command": [
        "mcp-server-postgres",
        "postgresql://user:password@127.0.0.1:5433/dbname"
      ]
    }
  }
}
```

### Gemini CLI (`~/.gemini/settings.json`)

```json
{
  "mcpServers": {
    "qgis": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/qgis_mcp/src/qgis_mcp",
        "run",
        "qgis_mcp_server.py"
      ]
    },
    "postgis": {
      "command": "mcp-server-postgres",
      "args": [
        "postgresql://user:password@127.0.0.1:5433/dbname"
      ]
    }
  }
}
```

## Prerequisites

### QGIS MCP

1. **Install QGIS plugin**: Copy `qgis_mcp_plugin/` to QGIS plugins folder:
   - Linux: `~/.local/share/QGIS/QGIS3/profiles/default/python/plugins/`
   - macOS: `~/Library/Application Support/QGIS/QGIS3/profiles/default/python/plugins/`
   - Windows: `%APPDATA%\QGIS\QGIS3\profiles\default\python\plugins\`

2. **Enable plugin**: In QGIS, go to Plugins > Manage and Install Plugins > enable "QGIS MCP"

3. **Install uv**: Required to run the MCP server
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

### PostGIS MCP

1. **Install mcp-server-postgres**:
   ```bash
   npm install -g @anthropics/mcp-server-postgres
   # or
   npx @anthropics/mcp-server-postgres
   ```

2. **Database access**: Ensure PostgreSQL/PostGIS is accessible (local or via tunnel)

## Setup Steps

### Step 1: Detect Current Tool

```bash
# Check which config files exist
ls -la ~/.claude/settings.json ~/.config/opencode/opencode.json ~/.gemini/settings.json 2>/dev/null
```

### Step 2: Check Existing Config

Read the appropriate config file and check if qgis/postgis entries exist.

### Step 3: Add Missing Entries

Use the format templates above. Key values to customize:
- `/path/to/qgis_mcp` - absolute path to the qgis_mcp repository
- `user:password` - database credentials
- `127.0.0.1:5433` - database host:port
- `dbname` - database name

### Step 4: Verify

Restart the AI tool and run `/mcp` to confirm servers appear.

## Troubleshooting

- **"command not found: uv"**: Install uv or use full path
- **"mcp-server-postgres not found"**: Install via npm globally
- **Server not appearing**: Check the tool's logs for startup errors
