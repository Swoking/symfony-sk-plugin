#!/bin/bash

# VM Health Check hook script
# Triggers the vm-health-check agent at session start

PROJECT_CONFIG=".claude/project.json"

# Check if config exists
if [ ! -f "$PROJECT_CONFIG" ]; then
    echo "SKIP_VM_CHECK: No project config found"
    exit 0
fi

# Config exists, request health check
echo "VM_HEALTH_CHECK_REQUIRED"
echo ""
echo "Run the vm-health-check agent to verify VM status:"
echo "- symfony-sk:vm-health-check"
echo ""
echo "This checks: ping, SSH, front, back (if exists), API"
