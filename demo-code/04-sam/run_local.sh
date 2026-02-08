#!/bin/bash
# AWS Lambda Workshop - Part 4: SAM Local Testing Script

set -e

echo "=========================================="
echo "AWS Lambda Workshop - SAM Local Testing"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v sam &> /dev/null; then
    echo -e "${RED}SAM CLI not found. Install from: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

echo -e "${GREEN}Prerequisites OK${NC}"
echo ""

# Build the project
echo "Building SAM project..."
sam build

echo ""
echo "=========================================="
echo "Local Testing Options"
echo "=========================================="
echo ""
echo "1. Invoke function directly:"
echo -e "${GREEN}   sam local invoke HelloWorldFunction -e events/event.json${NC}"
echo ""
echo "2. Start local API (runs until Ctrl+C):"
echo -e "${GREEN}   sam local start-api${NC}"
echo "   Then test with: curl http://localhost:3000/hello"
echo ""
echo "3. Run unit tests:"
echo -e "${GREEN}   pip install pytest && python -m pytest tests/ -v${NC}"
echo ""

# Ask what to do
echo "What would you like to do?"
echo "  1) Invoke function once"
echo "  2) Start local API server"
echo "  3) Run unit tests"
echo "  4) Exit"
read -p "Choice [1-4]: " choice

case $choice in
    1)
        echo ""
        echo "Invoking function with GET event..."
        sam local invoke HelloWorldFunction -e events/event.json
        echo ""
        echo "Invoking function with POST event..."
        sam local invoke HelloWorldFunction -e events/post_event.json
        ;;
    2)
        echo ""
        echo "Starting local API server..."
        echo "Test with: curl http://localhost:3000/hello"
        echo "Press Ctrl+C to stop"
        echo ""
        sam local start-api
        ;;
    3)
        echo ""
        echo "Installing pytest..."
        pip install pytest -q
        echo "Running tests..."
        python -m pytest tests/ -v
        ;;
    4)
        echo "Exiting..."
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
