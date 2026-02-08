#!/bin/bash
# AWS Lambda Workshop - Complete Cleanup Script
# Run this after the workshop to remove all AWS resources

set -e

echo "=========================================="
echo "AWS Lambda Workshop - Complete Cleanup"
echo "=========================================="
echo ""
echo "This will delete ALL resources created during the workshop:"
echo "  - CLI-deployed Lambda function and IAM role"
echo "  - CDK stack (Lambda + API Gateway)"
echo "  - SAM stack (Lambda + API Gateway)"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$SCRIPT_DIR/../demo-code"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "Cleaning up CLI resources..."
echo "=========================================="
if [ -f "$DEMO_DIR/02-cli/cleanup.sh" ]; then
    bash "$DEMO_DIR/02-cli/cleanup.sh" || echo -e "${YELLOW}CLI cleanup had issues (may already be deleted)${NC}"
fi

echo ""
echo "=========================================="
echo "Cleaning up CDK resources..."
echo "=========================================="
if [ -d "$DEMO_DIR/03-cdk/workshop-cdk" ]; then
    cd "$DEMO_DIR/03-cdk/workshop-cdk"
    source .venv/bin/activate 2>/dev/null || true
    cdk destroy --force || echo -e "${YELLOW}CDK cleanup had issues (may already be deleted)${NC}"
fi

echo ""
echo "=========================================="
echo "Cleaning up SAM resources..."
echo "=========================================="
if [ -f "$DEMO_DIR/04-sam/samconfig.toml" ]; then
    cd "$DEMO_DIR/04-sam"
    sam delete --no-prompts || echo -e "${YELLOW}SAM cleanup had issues (may already be deleted)${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Cleanup complete!${NC}"
echo "=========================================="
echo ""
echo "Note: The Console-created Lambda must be deleted manually from the AWS Console."
echo "Go to: AWS Console > Lambda > Functions > workshop-console-demo > Delete"
