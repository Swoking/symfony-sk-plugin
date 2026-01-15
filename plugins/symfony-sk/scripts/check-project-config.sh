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

# All good - output config for Claude to use
echo "Project configuration loaded:"
echo "- Code: $PROJECT_CODE"
echo "- URL: $PROJECT_URL"
echo "- Has Back Office: $HAS_BACK"
