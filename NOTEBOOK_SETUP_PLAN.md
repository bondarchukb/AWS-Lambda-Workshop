# AWS Lambda Workshop - Notebook Preparation Plan

## Overview
Prepare a fresh notebook to run the 1-hour AWS Lambda Workshop covering 4 deployment methods: Console, CLI, CDK, and SAM.

---

## Phase 1: Install Required Tools

### 1.1 Core Tools (in order)

| Tool | Install Command / Link | Verify |
|------|------------------------|--------|
| **Homebrew** (macOS) | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | `brew --version` |
| **Python 3.11+** | `brew install python@3.12` | `python3 --version` |
| **Node.js** | `brew install node` | `node --version` |
| **AWS CLI v2** | `brew install awscli` | `aws --version` |
| **AWS SAM CLI** | `brew install aws-sam-cli` | `sam --version` |
| **AWS CDK** | `npm install -g aws-cdk` | `cdk --version` |
| **Docker Desktop** | https://www.docker.com/products/docker-desktop/ | `docker --version` |

### 1.2 Quick Install Script (macOS)
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install python@3.12 node awscli aws-sam-cli
npm install -g aws-cdk

# Docker Desktop - download manually from docker.com
```

---

## Phase 2: Configure AWS Credentials

### 2.1 Get AWS Access Keys
1. Log into AWS Console
2. Go to IAM > Users > Your User > Security credentials
3. Create access key (CLI use case)
4. Save the Access Key ID and Secret Access Key

### 2.2 Configure on Notebook
```bash
aws configure
# Enter: Access Key ID
# Enter: Secret Access Key
# Enter: us-east-1 (default region)
# Enter: json (output format)
```

### 2.3 Verify Credentials
```bash
aws sts get-caller-identity
# Should show your Account ID and User ARN
```

---

## Phase 3: Transfer Workshop Files

### Option A: If Git Repo
```bash
git clone <your-repo-url>
cd "AWS Lambda Workshop"
```

### Option B: USB/Cloud Transfer
Copy entire `AWS Lambda Workshop/` folder to the notebook

### 3.1 Make Scripts Executable
```bash
cd "AWS Lambda Workshop"
chmod +x scripts/*.sh
chmod +x demo-code/*/*.sh
```

---

## Phase 4: Pre-Workshop Verification

### 4.1 Run Prerequisites Check
```bash
./scripts/check_prerequisites.sh
```

All items should show `[OK]`:
- [ ] AWS CLI v2
- [ ] SAM CLI
- [ ] Python 3.11+
- [ ] Node.js
- [ ] CDK
- [ ] Docker (installed)
- [ ] Docker (running)
- [ ] AWS credentials
- [ ] pip
- [ ] zip

### 4.2 Start Docker Desktop
**Important:** Launch Docker Desktop and wait for it to fully start before the workshop.

### 4.3 Bootstrap CDK (One-Time)
```bash
cdk bootstrap aws://$(aws sts get-caller-identity --query Account --output text)/us-east-1
```

---

## Phase 5: Optional Dry Run (Recommended)

Test each part works before the actual workshop:

### 5.1 Test CLI Deploy (Part 2)
```bash
cd demo-code/02-cli
./deploy.sh
./cleanup.sh  # Clean up after test
```

### 5.2 Test CDK Deploy (Part 3)
```bash
cd demo-code/03-cdk
./setup.sh
./cleanup.sh  # Clean up after test
```

### 5.3 Test SAM Local (Part 4)
```bash
cd demo-code/04-sam
./run_local.sh
# Press Ctrl+C to stop
```

---

## Day-of-Workshop Checklist

Morning of workshop:
- [ ] Start Docker Desktop (wait 2-3 min for full startup)
- [ ] Run `./scripts/check_prerequisites.sh` - all green
- [ ] Run `aws sts get-caller-identity` - credentials working
- [ ] Open AWS Console in browser, logged in
- [ ] Have `scripts/quick_commands.md` open for reference

---

## Troubleshooting Reference

| Issue | Solution |
|-------|----------|
| "Need to bootstrap" | Run `cdk bootstrap` command from Phase 4.3 |
| "Role cannot be assumed" | Wait 10 seconds (scripts handle this) |
| "Docker not running" | Start Docker Desktop, wait 2-3 min |
| "Access Denied" | Re-run `aws configure` with correct keys |
| CDK Python issues | Delete `.venv` folder, re-run `./setup.sh` |

---

## Files You'll Reference During Workshop

| File | Purpose |
|------|---------|
| `AWS_Lambda_Workshop_1Hour.md` | Main curriculum |
| `Workshop_Presenter_Script.txt` | Talking points |
| `AWS_Lambda_Cheat_Sheet.txt` | Quick command reference |
| `scripts/quick_commands.md` | Copy-paste commands |

---

## Cleanup After Workshop

```bash
./scripts/cleanup_all.sh
```

Or manually delete in AWS Console:
- Lambda functions: `workshop-console-demo`, `workshop-cli-demo`
- IAM role: `workshop-lambda-role`
- CloudFormation stacks: `WorkshopCdkStack`, `sam-app`
