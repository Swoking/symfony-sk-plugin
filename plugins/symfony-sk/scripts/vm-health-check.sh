#!/bin/bash

# VM Health Check hook script
# Triggers the vm-health-check agent at session start

PROJECT_CONFIG=".claude/project.json"

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

# Check if config exists
if [ ! -f "$PROJECT_CONFIG" ]; then
    output_json "SKIP_VM_CHECK: No project config found"
    exit 0
fi

# Config exists, request health check
MESSAGE="VM_HEALTH_CHECK_REQUIRED

Run the vm-health-check agent to verify VM status:
- symfony-sk:vm-health-check

This checks: ping, SSH, front, back (if exists), API"

output_json "$MESSAGE"
