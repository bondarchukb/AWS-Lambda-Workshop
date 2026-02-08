#!/bin/bash
# AWS Lambda Workshop - Part 3: CDK Cleanup Script

set -e

echo "=========================================="
echo "AWS Lambda Workshop - CDK Cleanup"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_DIR="$SCRIPT_DIR/workshop-cdk"

if [ -d "$WORKSHOP_DIR" ]; then
    cd "$WORKSHOP_DIR"
    source .venv/bin/activate 2>/dev/null || true

    echo "Destroying CDK stack..."
    cdk destroy --force

    echo ""
    echo "Do you want to remove the project folder? (y/n)"
    read -r response
    if [ "$response" = "y" ]; then
        cd "$SCRIPT_DIR"
        rm -rf "$WORKSHOP_DIR"
        echo "Project folder removed"
    fi
else
    echo "CDK project not found at $WORKSHOP_DIR"
fi

echo ""
echo "Cleanup complete!"
