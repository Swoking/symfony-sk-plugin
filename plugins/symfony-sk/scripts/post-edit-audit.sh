#!/bin/bash

# Post-edit audit hook - triggers after file modifications
# Returns instructions for Claude to run audit agents

FILE_PATH="$1"

# Skip if no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Determine which audits to run based on file type
AUDITS=""

case "$EXT" in
    php)
        AUDITS="code-audit security-audit side-effects-audit"
        # Check if it's a migration file
        if [[ "$FILE_PATH" == *"/migrations/"* ]] || [[ "$FILE_PATH" == *"/Migrations/"* ]]; then
            AUDITS="$AUDITS translation-audit"
        fi
        ;;
    js|ts|jsx|tsx)
        AUDITS="code-audit security-audit side-effects-audit"
        ;;
    twig|html)
        AUDITS="code-audit"
        ;;
    css|scss|sass|less)
        # Skip CSS files
        exit 0
        ;;
    *)
        # No audit for other file types
        exit 0
        ;;
esac

if [ -n "$AUDITS" ]; then
    echo "AUDIT_REQUIRED for: $FILE_PATH"
    echo ""
    echo "Run the following audit agents in parallel:"
    for AUDIT in $AUDITS; do
        echo "- symfony-sk:$AUDIT"
    done
    echo ""
    echo "Pass the file path to each agent for analysis."
fi
