#!/bin/bash
# AWS Lambda Workshop - Part 3: CDK Setup Script
# Run this to set up and deploy the CDK project

set -e

echo "=========================================="
echo "AWS Lambda Workshop - CDK Setup"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v cdk &> /dev/null; then
    echo -e "${RED}CDK CLI not found. Install with: npm install -g aws-cdk${NC}"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 not found${NC}"
    exit 1
fi

echo -e "${GREEN}Prerequisites OK${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_DIR="$SCRIPT_DIR/workshop-cdk"

# Step 1: Initialize CDK project
echo "Step 1: Initializing CDK project..."
if [ -d "$WORKSHOP_DIR" ]; then
    echo -e "${YELLOW}Project already exists, skipping init${NC}"
else
    mkdir -p "$WORKSHOP_DIR"
    cd "$WORKSHOP_DIR"
    cdk init app --language python

    # Activate virtual environment and install dependencies
    source .venv/bin/activate
    pip install -r requirements.txt
    pip install aws-cdk-lib constructs
fi

cd "$WORKSHOP_DIR"
source .venv/bin/activate

# Step 2: Copy Lambda code
echo ""
echo "Step 2: Copying Lambda handler..."
mkdir -p lambda
cp "$SCRIPT_DIR/lambda/handler.py" lambda/
echo -e "${GREEN}Lambda code copied${NC}"

# Step 3: Copy stack definition
echo ""
echo "Step 3: Copying stack definition..."
cp "$SCRIPT_DIR/workshop_cdk_stack.py" workshop_cdk/
echo -e "${GREEN}Stack definition copied${NC}"

# Step 4: Bootstrap CDK (if needed)
echo ""
echo "Step 4: Checking CDK bootstrap..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region || echo "us-east-1")

echo "Account: $ACCOUNT_ID, Region: $REGION"
echo "Running cdk bootstrap (safe to run multiple times)..."
cdk bootstrap aws://$ACCOUNT_ID/$REGION

# Step 5: Synthesize and deploy
echo ""
echo "Step 5: Synthesizing CloudFormation template..."
cdk synth

echo ""
echo "Step 6: Deploying..."
cdk deploy --require-approval never

echo ""
echo "=========================================="
echo -e "${GREEN}CDK Deployment complete!${NC}"
echo "=========================================="
echo ""
echo "Test your API with the URL shown above"
echo ""
echo "Useful commands:"
echo "  cdk diff      - Preview changes"
echo "  cdk deploy    - Deploy updates"
echo "  cdk destroy   - Remove all resources"
