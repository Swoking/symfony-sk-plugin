#!/bin/bash

# Check if project configuration exists in the current project's .claude directory
# This hook runs at session start to ensure we have the required project info

PROJECT_CONFIG=".claude/project.json"

# Helper function to output JSON format for Claude Code hooks
output_json() {
    local context="$1"
    # Use jq if available, otherwise use printf
    if command -v jq &>/dev/null; then
        jq -n --arg ctx "$context" '{
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": $ctx
            }
        }'
    else
        # Escape special characters for JSON
        context=$(echo "$context" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | tr '\n' ' ')
        printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$context"
    fi
}

# Check if config file exists
if [ ! -f "$PROJECT_CONFIG" ]; then
    MESSAGE="MISSING_CONFIG: No project configuration found at $PROJECT_CONFIG

ACTION_REQUIRED: Use AskUserQuestion to gather project information:
1. Project code (e.g., 'kotchi', 'myproject')
2. Project VM URL (e.g., 'kotchi2', 'myproject.dev')
3. Does the project have a back office? (yes/no)

Then create .claude/project.json with this structure:
{
  \"projectCode\": \"<code>\",
  \"projectUrl\": \"<url>\",
  \"hasBack\": true|false
}"
    output_json "$MESSAGE"
    exit 0
fi

# Config exists, validate required fields
PROJECT_CODE=$(grep -o '"projectCode"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_CONFIG" | sed 's/.*:.*"\([^"]*\)".*/\1/')
PROJECT_URL=$(grep -o '"projectUrl"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_CONFIG" | sed 's/.*:.*"\([^"]*\)".*/\1/')
HAS_BACK=$(grep -o '"hasBack"[[:space:]]*:[[:space:]]*[a-z]*' "$PROJECT_CONFIG" | sed 's/.*:[[:space:]]*//')

MISSING_FIELDS=""

if [ -z "$PROJECT_CODE" ]; then
    MISSING_FIELDS="$MISSING_FIELDS projectCode"
fi

if [ -z "$PROJECT_URL" ]; then
    MISSING_FIELDS="$MISSING_FIELDS projectUrl"
fi

if [ -z "$HAS_BACK" ]; then
    MISSING_FIELDS="$MISSING_FIELDS hasBack"
fi

if [ -n "$MISSING_FIELDS" ]; then
    MESSAGE="INCOMPLETE_CONFIG: Missing fields in $PROJECT_CONFIG:$MISSING_FIELDS

ACTION_REQUIRED: Use AskUserQuestion to gather missing information and update $PROJECT_CONFIG"
    output_json "$MESSAGE"
    exit 0
fi

# Check Claude permissions in .claude/settings.local.json
SETTINGS_FILE=".claude/settings.local.json"
REQUIRED_PERMISSIONS='["Read(**)", "Edit(**)", "Write(**)", "Bash(mkdir:*)", "Bash(find:*)", "Bash(ls:*)", "Bash(sed:*)", "Bash(grep:*)", "Bash(cat:*)", "Bash(rm:*)", "Bash(cp:*)", "Bash(mv:*)", "Bash(git:*)", "Bash(ssh:*)", "Bash(chmod:*)"]'

MISSING_PERMS=""

if [ ! -f "$SETTINGS_FILE" ]; then
    MISSING_PERMS="ALL"
else
    # Check for key permissions
    if ! grep -q '"Read(\*\*)"' "$SETTINGS_FILE" 2>/dev/null; then
        MISSING_PERMS="$MISSING_PERMS Read(**)"
    fi
    if ! grep -q '"Edit(\*\*)"' "$SETTINGS_FILE" 2>/dev/null; then
        MISSING_PERMS="$MISSING_PERMS Edit(**)"
    fi
    if ! grep -q '"Bash(git:\*)"' "$SETTINGS_FILE" 2>/dev/null; then
        MISSING_PERMS="$MISSING_PERMS Bash(git:*)"
    fi
    if ! grep -q '"Bash(ssh:\*)"' "$SETTINGS_FILE" 2>/dev/null; then
        MISSING_PERMS="$MISSING_PERMS Bash(ssh:*)"
    fi
fi

if [ -n "$MISSING_PERMS" ]; then
    MESSAGE="MISSING_PERMISSIONS: Claude may not have full access to this project

Missing permissions: $MISSING_PERMS

ACTION_REQUIRED: Use AskUserQuestion to ask user permission to update $SETTINGS_FILE

Required permissions to add in .claude/settings.local.json:
{
  \"permissions\": {
    \"allow\": [
      \"Read(**)\",
      \"Edit(**)\",
      \"Write(**)\",
      \"Bash(mkdir:*)\",
      \"Bash(find:*)\",
      \"Bash(ls:*)\",
      \"Bash(sed:*)\",
      \"Bash(grep:*)\",
      \"Bash(cat:*)\",
      \"Bash(rm:*)\",
      \"Bash(cp:*)\",
      \"Bash(mv:*)\",
      \"Bash(git:*)\",
      \"Bash(ssh:*)\",
      \"Bash(chmod:*)\"
    ]
  }
}"
    output_json "$MESSAGE"
    exit 0
fi

# All good - output config for Claude to use
MESSAGE="Project configuration loaded:
- Code: $PROJECT_CODE
- URL: $PROJECT_URL
- Has Back Office: $HAS_BACK
- Permissions: OK"
output_json "$MESSAGE"
