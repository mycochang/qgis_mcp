---
name: geo-mcp-status
description: Use this skill when the user asks about QGIS MCP status, PostGIS connection status, wants to check if MCP servers are running, troubleshoot MCP connectivity, or says "check geo mcp", "is qgis connected", "postgis status".
version: 1.0.0
---

# Geo MCP Status Check

Health check for QGIS and PostGIS MCP servers.

## What This Skill Does

Diagnoses the status of geospatial MCP servers by checking:
1. Configuration presence in the active tool's settings
2. Network connectivity (ports, tunnels)
3. Actual MCP server responsiveness

## Diagnostic Steps

### 1. Detect Current Tool

Determine which AI coding tool is running:
- **Claude Code**: Check `~/.claude/settings.json` for `mcpServers`
- **OpenCode**: Check `~/.config/opencode/opencode.json` for `mcp`
- **Gemini CLI**: Check `~/.gemini/settings.json` for `mcpServers`

### 2. Check QGIS MCP

```bash
# Check if configured (adapt path based on tool detected)
grep -l "qgis" ~/.claude/settings.json ~/.config/opencode/opencode.json ~/.gemini/settings.json 2>/dev/null

# Check if QGIS socket server is running (port 9876)
ss -tlnp 2>/dev/null | grep 9876 || echo "QGIS MCP socket not listening - open QGIS and start the plugin server"

# If port is open, try a ping via the MCP tool if available
```

### 3. Check PostGIS MCP

```bash
# Check if configured
grep -l "postgis\|postgres" ~/.claude/settings.json ~/.config/opencode/opencode.json ~/.gemini/settings.json 2>/dev/null

# Check if tunnel/port is open (default: 5433)
ss -tlnp 2>/dev/null | grep 5433 || echo "PostGIS port not listening - start the SSH tunnel"

# Test actual database connection
PGPASSWORD='<password>' psql -h 127.0.0.1 -p 5433 -U <user> -d <db> -c "SELECT 1" 2>&1
```

### 4. Report Status

Provide a summary table:

| Component | Configured | Port Open | Responsive |
|-----------|------------|-----------|------------|
| QGIS MCP  | ?          | ?         | ?          |
| PostGIS   | ?          | ?         | ?          |

## Common Issues

### QGIS MCP Not Responding
- QGIS application must be running
- Plugin must be enabled: Plugins > QGIS MCP > QGIS MCP
- Click "Start Server" in the plugin panel

### PostGIS Not Connecting
- SSH tunnel must be active: `~/repos/drone-sync/scripts/db_tunnel.sh`
- Check tunnel forwards to correct port (5433 -> remote:25432)
- Verify credentials in MCP config match database

### MCP Server Not Showing in /mcp
- MCP servers connect at session start
- Restart the AI tool after starting dependencies
- Check tool logs for connection errors
