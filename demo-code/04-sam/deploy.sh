#!/bin/bash
# AWS Lambda Workshop - Part 4: SAM Deploy Script

set -e

echo "=========================================="
echo "AWS Lambda Workshop - SAM Deployment"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build first
echo "Building SAM project..."
sam build

# Check if first deployment
if [ -f "samconfig.toml" ]; then
    echo ""
    echo "Found existing samconfig.toml, deploying..."
    sam deploy
else
    echo ""
    echo "First deployment - running guided setup..."
    echo "Accept defaults or customize as needed:"
    echo ""
    sam deploy --guided
fi

echo ""
echo "=========================================="
echo -e "${GREEN}SAM Deployment complete!${NC}"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  sam logs -n HelloWorldFunction --tail    - View logs"
echo "  sam sync --watch                         - Hot deploy changes"
echo "  sam delete                               - Remove all resources"
