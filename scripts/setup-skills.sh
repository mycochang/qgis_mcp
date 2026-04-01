#!/bin/bash
# Setup script to symlink QGIS MCP skills to AI tool config directories
# Works with: Claude Code, OpenCode, Gemini CLI

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"

# Skill directories to link
SKILLS=("geo-mcp-status" "geo-mcp-setup" "postgis-to-qgis")

# Target directories for each tool
CLAUDE_SKILLS="$HOME/.claude/skills"
OPENCODE_SKILLS="$HOME/.config/opencode/skills"
GEMINI_SKILLS="$HOME/.gemini/skills"

link_skills() {
    local target_dir="$1"
    local tool_name="$2"

    if [[ -d "$(dirname "$target_dir")" ]]; then
        mkdir -p "$target_dir"
        for skill in "${SKILLS[@]}"; do
            local src="$SKILLS_DIR/$skill"
            local dst="$target_dir/$skill"

            if [[ -L "$dst" ]]; then
                echo "  [$tool_name] $skill: already linked"
            elif [[ -d "$dst" ]]; then
                echo "  [$tool_name] $skill: directory exists (skipping)"
            else
                ln -s "$src" "$dst"
                echo "  [$tool_name] $skill: linked"
            fi
        done
    else
        echo "  [$tool_name] config dir not found (skipping)"
    fi
}

echo "QGIS MCP Skills Setup"
echo "====================="
echo "Source: $SKILLS_DIR"
echo ""

echo "Claude Code:"
link_skills "$CLAUDE_SKILLS" "Claude"
echo ""

echo "OpenCode:"
link_skills "$OPENCODE_SKILLS" "OpenCode"
echo ""

echo "Gemini CLI:"
link_skills "$GEMINI_SKILLS" "Gemini"
echo ""

echo "Done! Restart your AI tool to load the skills."
