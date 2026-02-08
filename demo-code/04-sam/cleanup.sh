#!/bin/bash
# AWS Lambda Workshop - Part 4: SAM Cleanup Script

set -e

echo "=========================================="
echo "AWS Lambda Workshop - SAM Cleanup"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Deleting SAM stack..."
sam delete --no-prompts

echo ""
echo "Cleanup complete!"
