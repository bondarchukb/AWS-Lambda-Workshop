# AWS Lambda Workshop

## Overview
This is a 1-hour hands-on workshop teaching Python developers how to deploy AWS Lambda functions using 4 methods: Console, CLI, CDK, and SAM.

## Target Audience
- Junior developers new to AWS Lambda
- Python developers learning serverless
- Workshop presenter (not self-paced)

## Project Structure

```
AWS Lambda Workshop/
├── AWS_Lambda_Workshop_1Hour.md    # Main workshop curriculum
├── AWS_Lambda_Cheat_Sheet.txt      # Command reference guide
├── Workshop_Presenter_Script.txt   # Presenter talking points
├── WORKSHOP_IMPROVEMENTS.md        # Known issues and fixes
│
├── demo-code/                      # Runnable sample code
│   ├── 01-console/                 # Part 1: AWS Console demo
│   ├── 02-cli/                     # Part 2: AWS CLI demo
│   ├── 03-cdk/                     # Part 3: CDK demo
│   └── 04-sam/                     # Part 4: SAM demo
│
└── scripts/                        # Workshop utilities
    ├── check_prerequisites.sh      # Verify setup before workshop
    ├── cleanup_all.sh              # Delete all AWS resources
    └── quick_commands.md           # Copy-paste reference
```

## Workshop Agenda (60 minutes)
1. **0:00-0:05** - Introduction & Setup Check
2. **0:05-0:15** - Deploy via AWS Console
3. **0:15-0:30** - Deploy via AWS CLI
4. **0:30-0:45** - Deploy via AWS CDK (Python)
5. **0:45-0:55** - Local Testing with SAM
6. **0:55-1:00** - Wrap-up & Cleanup

## Prerequisites
- AWS CLI v2
- SAM CLI
- Python 3.11+
- Node.js (for CDK)
- AWS CDK (`npm install -g aws-cdk`)
- Docker Desktop
- AWS account with credentials configured (`aws configure`)

## Key Commands

```bash
# Check prerequisites
./scripts/check_prerequisites.sh

# Run demos
cd demo-code/02-cli && ./deploy.sh      # CLI demo
cd demo-code/03-cdk && ./setup.sh       # CDK demo
cd demo-code/04-sam && ./run_local.sh   # SAM local testing

# Cleanup everything
./scripts/cleanup_all.sh
```

## Common Issues

| Issue | Solution |
|-------|----------|
| "Need to bootstrap" | Run `cdk bootstrap` |
| "Role cannot be assumed" | Wait 10 seconds after IAM role creation |
| "Docker not running" | Start Docker Desktop |
| "Access Denied" | Check `aws configure` credentials |

## AWS Resources Created

| Part | Resources | Function Name |
|------|-----------|---------------|
| Console | Lambda | `workshop-console-demo` |
| CLI | Lambda, IAM Role | `workshop-cli-demo` |
| CDK | Lambda, API Gateway, IAM | `WorkshopCdkStack` |
| SAM | Lambda, API Gateway | `sam-app` stack |

## Code Conventions
- All Lambda handlers use Python 3.12
- Handler signature: `def lambda_handler(event, context)` or `def handler(event, context)`
- Returns JSON with `statusCode`, `headers`, `body`
- Uses `datetime.now(timezone.utc)` (not deprecated `datetime.utcnow()`)

## When Helping with This Workshop

1. **Keep it simple** - Target audience is beginners
2. **Prefer scripts** - Use `./deploy.sh` over manual commands when possible
3. **Check prerequisites first** - Many issues are missing tools
4. **Remember cleanup** - Always mention cost implications and cleanup
5. **Test locally first** - SAM local testing before AWS deployment
