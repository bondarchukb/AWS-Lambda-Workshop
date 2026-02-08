#!/bin/bash
# AWS Lambda Workshop - Part 2: CLI Cleanup Script

set -e

echo "=========================================="
echo "AWS Lambda Workshop - CLI Cleanup"
echo "=========================================="

FUNCTION_NAME="workshop-cli-demo"
ROLE_NAME="workshop-lambda-role"

echo "Deleting Lambda function..."
aws lambda delete-function --function-name $FUNCTION_NAME 2>/dev/null || echo "Function not found or already deleted"

echo "Detaching IAM policies..."
aws iam detach-role-policy \
    --role-name $ROLE_NAME \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null || true

echo "Deleting IAM role..."
aws iam delete-role --role-name $ROLE_NAME 2>/dev/null || echo "Role not found or already deleted"

echo ""
echo "Cleanup complete!"
