#!/bin/bash
# SessionStart hook: Automatic SSH connection to project VM
# Reads connection info from .claude/project.json

PROJECT_CONFIG="$CLAUDE_PROJECT_DIR/.claude/project.json"

# Helper function to output JSON format for Claude Code hooks
output_json() {
    local context="$1"
    if command -v jq &>/dev/null; then
        jq -n --arg ctx "$context" '{
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": $ctx
            }
        }'
    else
        context=$(echo "$context" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | tr '\n' ' ')
        printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$context"
    fi
}

if [ ! -f "$PROJECT_CONFIG" ]; then
    output_json "No project.json found, skipping SSH"
    exit 0
fi

# Read SSH info from project.json
SSH_HOST=$(jq -r '.ssh.host // empty' "$PROJECT_CONFIG")
SSH_PASSWORD=$(jq -r '.ssh.password // empty' "$PROJECT_CONFIG")

if [ -z "$SSH_HOST" ] || [ -z "$SSH_PASSWORD" ]; then
    output_json "No SSH config in project.json, skipping"
    exit 0
fi

# SSH connection in master mode (ignore error if already connected)
if sshpass -p "$SSH_PASSWORD" ssh -MNf "$SSH_HOST" 2>/dev/null; then
    output_json "SSH connection established to $SSH_HOST"
else
    output_json "SSH master connection already active or failed (non-blocking)"
fi

exit 0
