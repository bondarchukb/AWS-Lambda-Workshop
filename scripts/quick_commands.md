# AWS Lambda Workshop - Quick Commands Reference

Use this during the workshop for copy-paste convenience.

---

## Pre-Workshop Setup

```bash
# Check all prerequisites
./scripts/check_prerequisites.sh

# Find your AWS Account ID
aws sts get-caller-identity --query Account --output text

# Check current region
aws configure get region
```

---

## Part 1: Console (Manual)

1. Go to: https://console.aws.amazon.com/lambda
2. Create function → Author from scratch
3. Name: `workshop-console-demo`
4. Runtime: Python 3.12
5. Copy code from: `demo-code/01-console/lambda_function.py`
6. Test with: `demo-code/01-console/test_event.json`

---

## Part 2: CLI

```bash
# Navigate to CLI demo
cd demo-code/02-cli

# Option A: Run automated script
./deploy.sh

# Option B: Manual steps
# 1. Create IAM role
aws iam create-role \
    --role-name workshop-lambda-role \
    --assume-role-policy-document file://trust-policy.json

# 2. Attach policy
aws iam attach-role-policy \
    --role-name workshop-lambda-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# 3. Wait for propagation
sleep 10

# 4. Create zip
zip -j function.zip lambda_function.py

# 5. Create function (replace ACCOUNT_ID)
aws lambda create-function \
    --function-name workshop-cli-demo \
    --runtime python3.12 \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::ACCOUNT_ID:role/workshop-lambda-role \
    --zip-file fileb://function.zip

# 6. Test
aws lambda invoke \
    --function-name workshop-cli-demo \
    --payload '{"test": "data"}' \
    --cli-binary-format raw-in-base64-out \
    response.json && cat response.json

# View logs
aws logs tail /aws/lambda/workshop-cli-demo --since 5m
```

---

## Part 3: CDK

```bash
# Navigate to CDK demo
cd demo-code/03-cdk

# Option A: Run automated script
./setup.sh

# Option B: Manual steps
# 1. Initialize project
mkdir workshop-cdk && cd workshop-cdk
cdk init app --language python

# 2. Activate virtual environment
source .venv/bin/activate  # Mac/Linux
# .venv\Scripts\activate   # Windows

# 3. Install dependencies
pip install -r requirements.txt
pip install aws-cdk-lib constructs

# 4. Copy files from demo-code/03-cdk/
cp ../lambda/handler.py lambda/
cp ../workshop_cdk_stack.py workshop_cdk/

# 5. Bootstrap CDK (one-time per account/region)
cdk bootstrap

# 6. Deploy
cdk synth
cdk deploy

# Test with the API URL from output
curl https://xxxxx.execute-api.region.amazonaws.com/prod/
```

---

## Part 4: SAM

```bash
# Navigate to SAM demo
cd demo-code/04-sam

# Build
sam build

# Local testing (requires Docker)
sam local invoke HelloWorldFunction -e events/event.json

# Start local API
sam local start-api
# Then: curl http://localhost:3000/hello

# Run unit tests
pip install pytest
python -m pytest tests/ -v

# Deploy to AWS
sam deploy --guided  # First time
sam deploy           # Subsequent

# View logs
sam logs -n HelloWorldFunction --tail

# Hot deploy during development
sam sync --watch
```

---

## Cleanup Commands

```bash
# Run complete cleanup
./scripts/cleanup_all.sh

# Or individual cleanup:

# Console - Delete manually in AWS Console

# CLI
aws lambda delete-function --function-name workshop-cli-demo
aws iam detach-role-policy --role-name workshop-lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name workshop-lambda-role

# CDK
cd demo-code/03-cdk/workshop-cdk
cdk destroy

# SAM
cd demo-code/04-sam
sam delete
```

---

## Troubleshooting

### "Need to bootstrap"
```bash
cdk bootstrap aws://ACCOUNT_ID/REGION
```

### "Role cannot be assumed"
Wait 10 seconds after creating IAM role.

### "Docker not running"
Start Docker Desktop before using SAM local.

### "Access Denied"
Check AWS credentials: `aws sts get-caller-identity`

### "Function not found"
Check region matches: `aws configure get region`
