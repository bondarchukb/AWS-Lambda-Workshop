#!/bin/bash
# AWS Lambda Workshop - Prerequisites Checker
# Run this BEFORE the workshop to verify everything is set up

echo "=========================================="
echo "AWS Lambda Workshop - Prerequisites Check"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Function to check command exists
check_command() {
    if command -v $1 &> /dev/null; then
        VERSION=$($2 2>&1 | head -1)
        echo -e "${GREEN}[OK]${NC} $1: $VERSION"
        return 0
    else
        echo -e "${RED}[MISSING]${NC} $1 is not installed"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check AWS credentials
check_aws_credentials() {
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
        REGION=$(aws configure get region)
        echo -e "${GREEN}[OK]${NC} AWS credentials configured (Account: $ACCOUNT, Region: $REGION)"
        return 0
    else
        echo -e "${RED}[MISSING]${NC} AWS credentials not configured"
        echo "    Run: aws configure"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check Docker is running
check_docker_running() {
    if docker info &> /dev/null; then
        echo -e "${GREEN}[OK]${NC} Docker is running"
        return 0
    else
        echo -e "${YELLOW}[WARNING]${NC} Docker is installed but not running"
        echo "    Start Docker Desktop before the SAM section"
        return 1
    fi
}

echo "Checking required tools..."
echo ""

# Check AWS CLI
check_command "aws" "aws --version"

# Check SAM CLI
check_command "sam" "sam --version"

# Check Python
check_command "python3" "python3 --version"

# Check CDK
check_command "cdk" "cdk --version"

# Check Node.js (required for CDK)
check_command "node" "node --version"

# Check Docker
check_command "docker" "docker --version"

echo ""
echo "Checking configurations..."
echo ""

# Check AWS credentials
check_aws_credentials

# Check Docker is running
check_docker_running

# Check Python pip
if python3 -m pip --version &> /dev/null; then
    echo -e "${GREEN}[OK]${NC} pip is available"
else
    echo -e "${YELLOW}[WARNING]${NC} pip may not be available"
fi

# Check zip command
if command -v zip &> /dev/null; then
    echo -e "${GREEN}[OK]${NC} zip command available"
else
    echo -e "${RED}[MISSING]${NC} zip command not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=========================================="

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All prerequisites are met!${NC}"
    echo "You're ready for the workshop."
else
    echo -e "${RED}$ERRORS prerequisite(s) missing.${NC}"
    echo "Please install the missing tools before the workshop."
fi

echo "=========================================="
echo ""
echo "Installation links:"
echo "  AWS CLI:    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
echo "  SAM CLI:    https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
echo "  CDK:        npm install -g aws-cdk"
echo "  Docker:     https://www.docker.com/products/docker-desktop/"
echo "  Python:     https://www.python.org/downloads/"
