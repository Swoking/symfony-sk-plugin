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
DOC_GEN=""

case "$EXT" in
    php)
        AUDITS="code-audit security-audit side-effects-audit"
        # Check if it's a migration file
        if [[ "$FILE_PATH" == *"/migrations/"* ]] || [[ "$FILE_PATH" == *"/Migrations/"* ]]; then
            AUDITS="$AUDITS translation-audit"
        else
            # Add doc-generator for non-migration PHP files
            DOC_GEN="doc-generator"
        fi
        ;;
    js|ts|jsx|tsx)
        AUDITS="code-audit security-audit side-effects-audit"
        DOC_GEN="doc-generator"
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

if [ -n "$AUDITS" ] || [ -n "$DOC_GEN" ]; then
    echo "POST_EDIT_ACTIONS for: $FILE_PATH"
    echo ""

    if [ -n "$AUDITS" ]; then
        echo "Run the following audit agents:"
        for AUDIT in $AUDITS; do
            echo "- symfony-sk:$AUDIT"
        done
        echo ""
    fi

    if [ -n "$DOC_GEN" ]; then
        echo "Run documentation generator:"
        echo "- symfony-sk:$DOC_GEN"
        echo ""
    fi

    echo "Pass the file path to each agent."
fi
