#!/bin/bash

# Check if project configuration exists in the current project's .claude directory
# This hook runs at session start to ensure we have the required project info

PROJECT_CONFIG=".claude/project.json"

# Check if config file exists
if [ ! -f "$PROJECT_CONFIG" ]; then
    echo "MISSING_CONFIG: No project configuration found at $PROJECT_CONFIG"
    echo ""
    echo "ACTION_REQUIRED: Use AskUserQuestion to gather project information:"
    echo "1. Project code (e.g., 'kotchi', 'myproject')"
    echo "2. Project VM URL (e.g., 'kotchi2', 'myproject.dev')"
    echo "3. Does the project have a back office? (yes/no)"
    echo ""
    echo "Then create .claude/project.json with this structure:"
    echo '{'
    echo '  "projectCode": "<code>",
'
    echo '  "projectUrl": "<url>",'
    echo '  "hasBack": true|false'
    echo '}'
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
    echo "INCOMPLETE_CONFIG: Missing fields in $PROJECT_CONFIG:$MISSING_FIELDS"
    echo ""
    echo "ACTION_REQUIRED: Use AskUserQuestion to gather missing information and update $PROJECT_CONFIG"
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
    echo "MISSING_PERMISSIONS: Claude may not have full access to this project"
    echo ""
    echo "Missing permissions: $MISSING_PERMS"
    echo ""
    echo "ACTION_REQUIRED: Use AskUserQuestion to ask user permission to update $SETTINGS_FILE"
    echo ""
    echo "Required permissions to add in .claude/settings.local.json:"
    echo '{'
    echo '  "permissions": {'
    echo '    "allow": ['
    echo '      "Read(**)",'
    echo '      "Edit(**)",'
    echo '      "Write(**)",'
    echo '      "Bash(mkdir:*)",'
    echo '      "Bash(find:*)",'
    echo '      "Bash(ls:*)",'
    echo '      "Bash(sed:*)",'
    echo '      "Bash(grep:*)",'
    echo '      "Bash(cat:*)",'
    echo '      "Bash(rm:*)",'
    echo '      "Bash(cp:*)",'
    echo '      "Bash(mv:*)",'
    echo '      "Bash(git:*)",'
    echo '      "Bash(ssh:*)",'
    echo '      "Bash(chmod:*)"'
    echo '    ]'
    echo '  }'
    echo '}'
    exit 0
fi

# All good - output config for Claude to use
echo "Project configuration loaded:"
echo "- Code: $PROJECT_CODE"
echo "- URL: $PROJECT_URL"
echo "- Has Back Office: $HAS_BACK"
echo "- Permissions: OK"
