#!/bin/bash
# AWS Lambda Workshop - Part 2: CLI Deployment Script
# This script automates the CLI deployment process

set -e  # Exit on any error

echo "=========================================="
echo "AWS Lambda Workshop - CLI Deployment"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get AWS Account ID automatically
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ -z "$ACCOUNT_ID" ]; then
    echo -e "${RED}ERROR: Cannot get AWS Account ID. Please configure AWS credentials.${NC}"
    echo "Run: aws configure"
    exit 1
fi

REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    REGION="us-east-1"
    echo -e "${YELLOW}No region configured, using default: ${REGION}${NC}"
fi

FUNCTION_NAME="workshop-cli-demo"
ROLE_NAME="workshop-lambda-role"

echo -e "${GREEN}AWS Account ID: ${ACCOUNT_ID}${NC}"
echo -e "${GREEN}Region: ${REGION}${NC}"
echo ""

# Step 1: Create IAM Role (if it doesn't exist)
echo "Step 1: Creating IAM Role..."
if aws iam get-role --role-name $ROLE_NAME 2>/dev/null; then
    echo -e "${YELLOW}Role already exists, skipping creation${NC}"
else
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file://trust-policy.json \
        --description "Lambda execution role for workshop"

    # Attach basic execution policy
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

    echo -e "${GREEN}IAM Role created successfully${NC}"
    echo "Waiting 10 seconds for role propagation..."
    sleep 10
fi

# Step 2: Create deployment package
echo ""
echo "Step 2: Creating deployment package..."
zip -j function.zip lambda_function.py
echo -e "${GREEN}Created function.zip${NC}"

# Step 3: Create or update Lambda function
echo ""
echo "Step 3: Deploying Lambda function..."
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

if aws lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
    echo "Function exists, updating code..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://function.zip
else
    echo "Creating new function..."
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime python3.12 \
        --handler lambda_function.lambda_handler \
        --role $ROLE_ARN \
        --zip-file fileb://function.zip \
        --timeout 10 \
        --memory-size 256
fi

echo -e "${GREEN}Lambda function deployed successfully${NC}"

# Wait for function to become active
echo "Waiting for function to become active..."
aws lambda wait function-active --function-name $FUNCTION_NAME
echo -e "${GREEN}Function is now active${NC}"

# Step 4: Test the function
echo ""
echo "Step 4: Testing the function..."
aws lambda invoke \
    --function-name $FUNCTION_NAME \
    --payload fileb://test_event.json \
    --cli-binary-format raw-in-base64-out \
    response.json

echo ""
echo -e "${GREEN}Response:${NC}"
cat response.json
echo ""

# Cleanup temp files
rm -f function.zip

echo ""
echo "=========================================="
echo -e "${GREEN}Deployment complete!${NC}"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  Invoke:  aws lambda invoke --function-name $FUNCTION_NAME --payload '{\"test\":\"data\"}' --cli-binary-format raw-in-base64-out out.json && cat out.json"
echo "  Logs:    aws logs tail /aws/lambda/$FUNCTION_NAME --since 5m"
echo "  Delete:  aws lambda delete-function --function-name $FUNCTION_NAME"
