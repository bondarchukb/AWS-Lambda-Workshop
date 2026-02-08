# AWS Lambda Workshop - Improvements & Fixes

This document summarizes issues found and improvements made to the workshop.

---

## Critical Issues Fixed

### 1. CDK Bootstrap Missing (WILL CAUSE FAILURE)

**Problem:** The original workshop doesn't mention `cdk bootstrap`. First-time CDK users will get an error.

**Fix:** Added to Part 3 instructions:
```bash
# REQUIRED: One-time bootstrap per AWS account/region
cdk bootstrap aws://$(aws sts get-caller-identity --query Account --output text)/$(aws configure get region)
```

### 2. ACCOUNT_ID Not Explained

**Problem:** Line 144 says "replace ACCOUNT_ID" but doesn't explain how to find it.

**Fix:** Added command:
```bash
# Find your AWS Account ID
aws sts get-caller-identity --query Account --output text
```

### 3. datetime.utcnow() Deprecated

**Problem:** Python 3.12 deprecates `datetime.utcnow()`.

**Fix:** Use instead:
```python
from datetime import datetime, timezone
datetime.now(timezone.utc).isoformat()
```

### 4. pytest Not Pre-installed

**Problem:** `python -m pytest tests/ -v` fails if pytest isn't installed.

**Fix:** Added explicit install step:
```bash
pip install pytest
python -m pytest tests/ -v
```

### 5. IAM Role Propagation Delay

**Problem:** Creating an IAM role and immediately using it can fail.

**Fix:** Added 10-second wait:
```bash
# Wait for IAM role to propagate
sleep 10
```

---

## New Demo Code Structure

Created complete runnable examples in `demo-code/`:

```
demo-code/
├── 01-console/
│   ├── lambda_function.py    # Copy to Console
│   └── test_event.json       # Test event JSON
│
├── 02-cli/
│   ├── lambda_function.py    # Lambda code
│   ├── trust-policy.json     # IAM trust policy
│   ├── test_event.json       # Test event
│   ├── deploy.sh             # Automated deployment
│   └── cleanup.sh            # Cleanup script
│
├── 03-cdk/
│   ├── lambda/
│   │   └── handler.py        # Lambda handler
│   ├── workshop_cdk_stack.py # CDK stack definition
│   ├── setup.sh              # Automated setup & deploy
│   └── cleanup.sh            # Cleanup script
│
└── 04-sam/
    ├── template.yaml         # SAM template
    ├── hello_world/
    │   ├── app.py            # Lambda handler
    │   ├── requirements.txt  # Dependencies
    │   └── __init__.py
    ├── events/
    │   ├── event.json        # GET test event
    │   └── post_event.json   # POST test event
    ├── tests/
    │   ├── test_handler.py   # Unit tests
    │   └── __init__.py
    ├── run_local.sh          # Local testing script
    ├── deploy.sh             # Deployment script
    └── cleanup.sh            # Cleanup script
```

---

## New Utility Scripts

Created in `scripts/`:

| Script | Purpose |
|--------|---------|
| `check_prerequisites.sh` | Run BEFORE workshop to verify setup |
| `cleanup_all.sh` | Delete ALL AWS resources after workshop |
| `quick_commands.md` | Copy-paste reference for presenter |

---

## Recommended Workshop Flow

### Before Workshop
```bash
# 1. Verify everything works
./scripts/check_prerequisites.sh

# 2. Pre-deploy CLI demo (optional, saves time)
cd demo-code/02-cli && ./deploy.sh
```

### During Workshop

**Part 1 - Console (10 min)**
- Show `demo-code/01-console/lambda_function.py` on screen
- Attendees copy code to Console
- Use `test_event.json` for testing

**Part 2 - CLI (15 min)**
- Option A: Run `./deploy.sh` for quick demo
- Option B: Walk through commands manually

**Part 3 - CDK (15 min)**
- Run `./setup.sh` for automated demo
- OR walk through manual steps
- **Don't forget `cdk bootstrap`!**

**Part 4 - SAM (10 min)**
- Run `./run_local.sh` for interactive testing
- Show local API with `sam local start-api`
- Optional: Deploy with `./deploy.sh`

### After Workshop
```bash
./scripts/cleanup_all.sh
```

---

## Documentation Clarity Improvements

### For Beginners - Add These Explanations:

1. **What is a Trust Policy?**
   > A trust policy tells AWS which services can "assume" (use) this IAM role. We allow Lambda to use the role.

2. **Why do we need an IAM Role?**
   > Lambda functions run with limited permissions by default. The role grants permissions to access AWS services like CloudWatch Logs.

3. **What does `handler='handler.handler'` mean?**
   > Format is `filename.function_name`. File `handler.py` contains function `handler()`.

4. **What is CDK Bootstrap?**
   > Creates an S3 bucket and IAM roles in your account that CDK uses to deploy. Run once per account/region.

5. **Why does SAM need Docker?**
   > SAM runs your Lambda locally inside a Docker container that matches the AWS Lambda environment.

---

## Suggested Documentation Updates

### Update Prerequisites Section

Add after line 35:
```markdown
# Find your AWS Account ID (you'll need this later)
aws sts get-caller-identity --query Account --output text

# Set your preferred region (if not already set)
aws configure set region us-east-1
```

### Update CLI Section (Part 2)

Change line 144 from:
```bash
--role arn:aws:iam::ACCOUNT_ID:role/workshop-lambda-role
```
To:
```bash
--role arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/workshop-lambda-role
```

### Update CDK Section (Part 3)

Add after line 220 (after `pip install`):
```markdown
### 3.1.1 Bootstrap CDK (First-time Only)
```bash
# Required one-time setup per account/region
cdk bootstrap
```
If you see "Need to bootstrap" error, run this command.
```

### Update datetime Usage

Change all instances of:
```python
datetime.utcnow().isoformat()
```
To:
```python
datetime.now(timezone.utc).isoformat()
```
And add import:
```python
from datetime import datetime, timezone
```

---

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Need to bootstrap" | CDK not initialized | `cdk bootstrap` |
| "Role cannot be assumed" | IAM propagation delay | Wait 10 seconds |
| "Access Denied" | Missing credentials | `aws configure` |
| "Function not found" | Wrong region | Check `aws configure get region` |
| "Docker not running" | Docker Desktop closed | Start Docker Desktop |
| "Module not found" | Not in venv | `source .venv/bin/activate` |
| "sam local" hangs | Docker issue | Restart Docker Desktop |

---

## Cost Warning

Add to workshop introduction:

> **Cost Notice:** This workshop creates AWS resources that may incur charges.
> - Lambda: Free tier includes 1M requests/month
> - API Gateway: Free tier includes 1M calls/month
> - CloudWatch Logs: Free tier includes 5GB/month
>
> **Important:** Run cleanup commands after the workshop to avoid unexpected charges.

---

## Recommended Additions for Future Versions

1. **Architecture diagrams** showing Lambda + API Gateway flow
2. **Video walkthrough** for self-paced learners
3. **Pre-built project repository** attendees can clone
4. **Troubleshooting section** in main documentation
5. **Slack/Discord channel** for questions during workshop
