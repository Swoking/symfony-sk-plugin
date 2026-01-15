#!/bin/bash
# SessionStart hook: Automatic SSH connection to project VM
# Reads connection info from .claude/project.json

PROJECT_CONFIG="$CLAUDE_PROJECT_DIR/.claude/project.json"

if [ ! -f "$PROJECT_CONFIG" ]; then
    echo "No project.json found, skipping SSH"
    exit 0
fi

# Read SSH info from project.json
SSH_HOST=$(jq -r '.ssh.host // empty' "$PROJECT_CONFIG")
SSH_PASSWORD=$(jq -r '.ssh.password // empty' "$PROJECT_CONFIG")

if [ -z "$SSH_HOST" ] || [ -z "$SSH_PASSWORD" ]; then
    echo "No SSH config in project.json, skipping"
    exit 0
fi

# SSH connection in master mode (ignore error if already connected)
sshpass -p "$SSH_PASSWORD" ssh -MNf "$SSH_HOST" 2>/dev/null || true

exit 0
