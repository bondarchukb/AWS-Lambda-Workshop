# AWS Lambda Workshop for Python Developers - 1 Hour Intensive

## Workshop Overview

**Duration:** 60 minutes
**Audience:** Python Developers
**Format:** Fast-paced demo + hands-on
**Goal:** Deploy Lambda using Console → CLI → CDK, plus local testing with SAM

> **Cost Notice:** This workshop creates AWS resources that may incur small charges.
> Lambda, API Gateway, and CloudWatch Logs all have generous free tiers (1M requests, 1M calls, 5GB logs per month).
> **Run the cleanup commands at the end to avoid unexpected charges.**

---

## Agenda

| Time | Topic | Demo Code |
|------|-------|-----------|
| 0:00-0:05 | Introduction & Setup Check | `scripts/check_prerequisites.sh` |
| 0:05-0:15 | Deploy via AWS Console | `demo-code/01-console/` |
| 0:15-0:30 | Deploy via AWS CLI | `demo-code/02-cli/` |
| 0:30-0:45 | Deploy via AWS CDK (Python) | `demo-code/03-cdk/` |
| 0:45-0:55 | Local Testing with SAM | `demo-code/04-sam/` |
| 0:55-1:00 | Wrap-up & Cleanup | `scripts/cleanup_all.sh` |

---

## Prerequisites (Complete Before Workshop)

```bash
# Required tools - verify each one
aws --version          # AWS CLI v2
sam --version          # SAM CLI
python3 --version      # Python 3.11+
cdk --version          # AWS CDK
docker --version       # Docker Desktop (must be running)

# AWS credentials must be configured
aws sts get-caller-identity

# Find your AWS Account ID (you'll need this in Part 2)
aws sts get-caller-identity --query Account --output text

# Verify your region (set one if not configured)
aws configure get region
# aws configure set region us-east-1   # uncomment to set default

# For CDK Python projects
pip install aws-cdk-lib constructs
```

> **Tip:** Run `./scripts/check_prerequisites.sh` to verify everything at once.

---

## Part 1: AWS Console (10 min)

> **What you'll learn:** The visual way to create and test Lambda functions.
> Console is great for learning and debugging, but not for production deployments.

### 1.1 Create Lambda Function

1. Open AWS Console → Lambda → **Create function**
2. Select **Author from scratch**
3. Settings:
   - Name: `workshop-console-demo`
   - Runtime: `Python 3.12`
   - Architecture: `x86_64`
4. Click **Create function**

> **What just happened?** AWS automatically created an IAM execution role for your function.
> This role gives Lambda permission to write logs to CloudWatch.

### 1.2 Add Code

Paste this into the Lambda code editor (or copy from `demo-code/01-console/lambda_function.py`):

```python
import json

def lambda_handler(event, context):
    """
    Lambda handler - the entry point for every invocation.
    - event: dict containing input data (from API Gateway, S3, SQS, etc.)
    - context: runtime info (function name, memory limit, time remaining)
    """
    print(f"Event: {json.dumps(event)}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Console Lambda!',
            'input': event
        })
    }
```

Click **Deploy** to save your changes.

### 1.3 Test

1. Click **Test** → Create test event
2. Event name: `test1`
3. Use default JSON or: `{"name": "Workshop"}`
4. Click **Test** → View results

You should see:
- **Execution result:** succeeded
- The response body with your message
- Duration, billed duration, and memory used

### 1.4 View Logs

- Click **Monitor** tab → **View CloudWatch logs**
- Each invocation logs: START, your print statements, END, and a REPORT with billing info

> **Key Takeaway:** Console is great for learning and quick debugging.
> It's NOT suited for production (no version control, no repeatable deployments, no team collaboration).

---

## Part 2: AWS CLI (15 min)

> **What you'll learn:** Deploy Lambda from the terminal -- scriptable, automatable, CI/CD-ready.
>
> **Quick option:** Run `cd demo-code/02-cli && ./deploy.sh` to deploy automatically,
> or follow the manual steps below to understand each command.

### 2.1 Create IAM Role

> **Why do we need an IAM Role?** Lambda functions need permissions to access AWS services.
> The role grants permission to write logs to CloudWatch. Without it, Lambda can't run.

> **What is a Trust Policy?** It tells AWS which services can "assume" (use) this role.
> Here we allow the Lambda service to assume it.

```bash
# Create trust policy file
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

# Create the role
aws iam create-role \
  --role-name workshop-lambda-role \
  --assume-role-policy-document file://trust-policy.json

# Attach the basic execution policy (allows writing to CloudWatch Logs)
aws iam attach-role-policy \
  --role-name workshop-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# IMPORTANT: Wait for IAM role to propagate across AWS
# Skipping this may cause "The role cannot be assumed" errors
sleep 10

# Get and save the role ARN -- you'll need it next
aws iam get-role --role-name workshop-lambda-role --query 'Role.Arn' --output text
```

### 2.2 Create Function Code

```bash
# Create function file
cat > lambda_function.py << 'EOF'
import json
from datetime import datetime, timezone

def lambda_handler(event, context):
    print(f"Event: {json.dumps(event)}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from CLI Lambda!',
            'timestamp': datetime.now(timezone.utc).isoformat()
        })
    }
EOF

# Create deployment package (zip must contain .py files at the root level)
zip function.zip lambda_function.py
```

### 2.3 Deploy Function

```bash
# Get your Account ID automatically
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create the Lambda function
aws lambda create-function \
  --function-name workshop-cli-demo \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::${ACCOUNT_ID}:role/workshop-lambda-role
```

> **Breaking down the parameters:**
> - `--handler lambda_function.lambda_handler` = file `lambda_function.py`, function `lambda_handler()`
> - `--zip-file fileb://` = `fileb://` means binary file (not `file://`)
> - `--role` = the IAM role ARN from the previous step

### 2.4 Invoke & Update

```bash
# Invoke the function
aws lambda invoke \
  --function-name workshop-cli-demo \
  --payload '{"name": "CLI Workshop"}' \
  --cli-binary-format raw-in-base64-out \
  response.json && cat response.json

# Update code (after making changes to lambda_function.py)
zip function.zip lambda_function.py
aws lambda update-function-code \
  --function-name workshop-cli-demo \
  --zip-file fileb://function.zip

# Update configuration (memory and timeout)
aws lambda update-function-configuration \
  --function-name workshop-cli-demo \
  --memory-size 256 \
  --timeout 10
```

### 2.5 Deploy with Dependencies (Bonus)

```bash
# Create requirements.txt
echo "requests==2.31.0" > requirements.txt

# Install dependencies into a package directory
pip install -r requirements.txt -t package/

# Copy your lambda code into the package directory
cp lambda_function.py package/

# Create deployment package (everything at zip root level -- Lambda expects this)
cd package && zip -r ../function.zip . && cd ..

# Update the function with the new package
aws lambda update-function-code \
  --function-name workshop-cli-demo \
  --zip-file fileb://function.zip
```

> **Tip:** For larger dependencies, use Lambda Layers instead of bundling.
> See the cheat sheet (`AWS_Lambda_Cheat_Sheet.txt`) for layer commands.

### 2.6 Useful CLI Commands

```bash
# List all functions
aws lambda list-functions --query 'Functions[].FunctionName'

# Get function details
aws lambda get-function --function-name workshop-cli-demo

# View recent logs
aws logs tail /aws/lambda/workshop-cli-demo --since 5m

# Delete function (we'll do this in cleanup)
aws lambda delete-function --function-name workshop-cli-demo
```

> **Key Takeaway:** CLI is great for scripting, CI/CD pipelines, and quick operations.
> But for complex infrastructure with multiple resources, you want Infrastructure as Code.

---

## Part 3: AWS CDK with Python (15 min)

> **What you'll learn:** Define cloud infrastructure in Python code -- type-safe, reusable, version-controlled.
> CDK generates CloudFormation templates and deploys them for you.
>
> **Quick option:** Run `cd demo-code/03-cdk && ./setup.sh` to deploy automatically,
> or follow the manual steps below.

### 3.1 Bootstrap CDK (First-Time Only)

> **What is CDK Bootstrap?** It creates an S3 bucket and IAM roles in your account
> that CDK needs to store and deploy assets. You only run this once per account/region.

```bash
# Required one-time setup -- skip if you've done this before
cdk bootstrap
```

> **Getting "Need to bootstrap" errors later?** Come back and run this command.

### 3.2 Initialize Project

```bash
mkdir workshop-cdk && cd workshop-cdk
cdk init app --language python

# Activate virtual environment
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt
pip install aws-cdk-lib constructs
```

### 3.3 Create Lambda Code

```bash
# Create lambda directory
mkdir lambda

# Create handler
cat > lambda/handler.py << 'EOF'
import json
from datetime import datetime, timezone

def handler(event, context):
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'message': 'Hello from CDK Lambda!',
            'path': event.get('path', '/'),
            'timestamp': datetime.now(timezone.utc).isoformat()
        })
    }
EOF
```

### 3.4 Create CDK Stack

Edit `workshop_cdk/workshop_cdk_stack.py`:

```python
from aws_cdk import (
    Stack,
    Duration,
    CfnOutput,
    aws_lambda as _lambda,
    aws_apigateway as apigw,
)
from constructs import Construct

class WorkshopCdkStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Lambda Function
        # 'handler.handler' = file handler.py, function handler()
        # 'lambda' folder = directory containing handler.py
        fn = _lambda.Function(
            self, 'WorkshopFunction',
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler='handler.handler',
            code=_lambda.Code.from_asset('lambda'),
            memory_size=256,
            timeout=Duration.seconds(10),
            environment={
                'ENVIRONMENT': 'workshop'
            }
        )

        # API Gateway -- routes all HTTP requests to our Lambda
        api = apigw.LambdaRestApi(
            self, 'WorkshopApi',
            handler=fn,
            proxy=True,
        )

        # Output the API URL so we can test it
        CfnOutput(
            self, 'ApiUrl',
            value=api.url,
            description='API Gateway URL',
        )
```

> **Notice:** ~20 lines of Python creates a Lambda function AND an API Gateway with full IAM roles.
> Compare that to the manual CLI steps above!

### 3.5 Deploy

```bash
# Preview the CloudFormation template CDK will generate
cdk synth

# Check what resources will be created/changed
cdk diff

# Deploy (CDK will show IAM changes and ask for confirmation -- type 'y')
cdk deploy

# Note the API URL in the Outputs section!
```

### 3.6 Test & Cleanup

```bash
# Test the API (replace with your actual URL from the deploy output)
curl https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/

# Cleanup -- removes ALL resources CDK created
cdk destroy
```

### 3.7 CDK with Lambda Layers (Bonus)

```python
# Create a layer for shared dependencies
deps_layer = _lambda.LayerVersion(
    self, 'DependenciesLayer',
    code=_lambda.Code.from_asset('layers/dependencies'),
    compatible_runtimes=[_lambda.Runtime.PYTHON_3_12],
    description='Shared Python dependencies'
)

fn = _lambda.Function(
    self, 'WorkshopFunction',
    runtime=_lambda.Runtime.PYTHON_3_12,
    handler='handler.handler',
    code=_lambda.Code.from_asset('lambda'),
    layers=[deps_layer],  # Attach layer
)
```

> **Key Takeaway:** CDK is best for Infrastructure as Code -- reusable constructs, type safety, and managing complex architectures with multiple resources.

---

## Part 4: Local Testing with SAM (10 min)

> **What you'll learn:** Test Lambda functions on your local machine before deploying.
> This saves time (no waiting for deploys), saves money (no AWS charges), and catches bugs early.
>
> **Prerequisite:** Docker Desktop must be running. SAM uses Docker to simulate the Lambda runtime.
>
> **Quick option:** Run `cd demo-code/04-sam && ./run_local.sh` for an interactive demo.

### 4.1 Initialize SAM Project

```bash
sam init --runtime python3.12 --name workshop-sam --app-template hello-world
cd workshop-sam
```

### 4.2 Project Structure

```
workshop-sam/
├── hello_world/
│   ├── __init__.py
│   ├── app.py           # Lambda handler
│   └── requirements.txt # Dependencies
├── events/
│   └── event.json       # Test events
├── template.yaml        # SAM/CloudFormation template (infrastructure definition)
└── tests/               # Unit tests
```

### 4.3 Build & Invoke Locally

```bash
# Build the application (installs dependencies, prepares code)
sam build

# Invoke locally (runs your Lambda in a Docker container)
sam local invoke HelloWorldFunction -e events/event.json

# Or pass a custom event inline
echo '{"name": "Local Test"}' | sam local invoke HelloWorldFunction --event -
```

> **First run is slow** -- Docker needs to pull the Lambda runtime image.
> Subsequent invocations are much faster.

### 4.4 Local API

```bash
# Start a local API Gateway on localhost:3000
sam local start-api

# Test in another terminal
curl http://localhost:3000/hello
```

### 4.5 Generate Sample Events

```bash
# SAM can generate realistic event payloads for different AWS services
sam local generate-event apigateway aws-proxy > events/api-event.json
sam local generate-event s3 put > events/s3-event.json
sam local generate-event sqs receive-message > events/sqs-event.json
sam local generate-event dynamodb update > events/dynamodb-event.json
```

### 4.6 Unit Testing with pytest

```bash
# Install test dependencies
pip install pytest pytest-mock

# Run tests
python -m pytest tests/ -v
```

Example test (`tests/unit/test_handler.py`):

```python
import json
from hello_world import app

def test_lambda_handler():
    event = {
        'httpMethod': 'GET',
        'path': '/hello'
    }

    response = app.lambda_handler(event, None)

    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert 'message' in body
```

### 4.7 Deploy from SAM

```bash
# Guided deployment (first time -- walks you through stack name, region, etc.)
sam deploy --guided

# Subsequent deployments (uses saved config)
sam deploy

# Cleanup
sam delete
```

> **Key Takeaway:** SAM CLI is essential for local development. Always test locally first, then deploy.

---

## Quick Comparison

| Method | Best For | IaC | Local Testing | Deployment |
|--------|----------|-----|---------------|------------|
| Console | Learning, debugging | No | No | Manual (click) |
| CLI | Scripts, CI/CD, quick ops | No | No | Fast (commands) |
| CDK | Complex infra, reusability | Yes | No | Medium (synthesize + deploy) |
| SAM | Serverless apps, local dev | Yes | Yes | Medium (build + deploy) |

**In real projects, you'll often combine these:** CDK for infrastructure, SAM for local testing, CLI for quick operations.

---

## Cleanup Commands

> **Important:** Run these after the workshop to avoid charges.
> Or use the automated script: `./scripts/cleanup_all.sh`

```bash
# Delete Console function
aws lambda delete-function --function-name workshop-console-demo

# Delete CLI function and IAM role
aws lambda delete-function --function-name workshop-cli-demo
aws iam detach-role-policy \
  --role-name workshop-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name workshop-lambda-role

# Delete CDK stack
cd workshop-cdk && cdk destroy

# Delete SAM stack
cd workshop-sam && sam delete
```

---

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Unable to locate credentials` | AWS CLI not configured | Run `aws configure` |
| `Access Denied` | Wrong/expired credentials | Check `aws sts get-caller-identity` |
| `The role cannot be assumed` | IAM propagation delay | Wait 10 seconds after role creation |
| `Function not found` | Wrong region | Check `aws configure get region` |
| `Need to bootstrap` | CDK not initialized for account/region | Run `cdk bootstrap` |
| `Module not found` (CDK) | Virtual environment not active | Run `source .venv/bin/activate` |
| `Docker not running` | Docker Desktop not started | Start Docker Desktop |
| `sam local` hangs | Docker issue | Restart Docker Desktop |

---

## Python-Specific Tips

### Handler Signature

```python
def lambda_handler(event, context):
    # event: dict - Input data (from API Gateway, S3, SQS, etc.)
    # context: LambdaContext - Runtime info (see attributes below)
    return response
```

### Context Object Attributes

```python
context.function_name                    # Function name
context.function_version                 # Version ($LATEST or number)
context.memory_limit_in_mb              # Allocated memory
context.aws_request_id                  # Unique invocation ID
context.get_remaining_time_in_millis()  # Time left before timeout
```

### Common Patterns

```python
# JSON response for API Gateway
return {
    'statusCode': 200,
    'headers': {'Content-Type': 'application/json'},
    'body': json.dumps({'key': 'value'})
}

# Environment variables
import os
TABLE_NAME = os.environ.get('TABLE_NAME', 'default-table')

# Structured logging
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.info('Processing event')
```

---

## Next Steps / Resources

- **AWS Lambda Python Docs:** https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html
- **SAM Documentation:** https://docs.aws.amazon.com/serverless-application-model/
- **CDK Python Reference:** https://docs.aws.amazon.com/cdk/api/v2/python/
- **Lambda Powertools for Python:** https://docs.powertools.aws.dev/lambda/python/
- **Serverless Patterns:** https://serverlessland.com/patterns
- **CDK Workshop (extended):** https://cdkworkshop.com
