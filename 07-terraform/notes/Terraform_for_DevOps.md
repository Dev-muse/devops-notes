# 🏗️ Terraform for DevOps — Complete Guide

> **Continued from:** Linux, Bash, Git, Docker, and AWS. You know how to provision resources manually in the AWS console and via the CLI. Terraform takes everything you've done by hand and turns it into repeatable, version-controlled code.
>
> **How to use this document:** Work through it in order the first time. Plain-English explanation first, technical detail second, real code you can copy and run third. Come back to any section whenever you need a refresher.
>
> **The goal:** Understand what Infrastructure as Code is and why it exists, write Terraform configuration to provision real AWS infrastructure, manage state correctly, use variables and modules to build reusable code, master the advanced patterns used in production, and answer Terraform questions confidently in interviews.

---

# Chapter 1 — Infrastructure as Code

## 1.1 What is Infrastructure as Code?

Before IaC, provisioning infrastructure meant clicking through consoles, running CLI commands, or SSHing into servers and running scripts manually. This worked fine for one server. It became a nightmare for ten. For a hundred, it was impossible to do consistently.

**Infrastructure as Code (IaC)** means describing your infrastructure — servers, networks, databases, load balancers — in text files that can be read, version-controlled, reviewed, and executed automatically. The file *is* the infrastructure.

The benefits are transformative:

| Benefit | What it means |
|---|---|
| **Consistency** | Every environment (dev, staging, prod) is built from the same code. No manual drift. |
| **Reproducibility** | Destroy your entire infrastructure and rebuild it exactly from the code in minutes. |
| **Version control** | Infrastructure changes go through Git. PRs, code review, history, rollback. |
| **Speed** | Spin up a complete environment in minutes instead of hours or days. |
| **Documentation** | The code *is* the documentation. It shows exactly what exists and how it's configured. |
| **Collaboration** | Teams can review and contribute to infrastructure the same way they do to application code. |

## 1.2 IaC with Version Control

Storing infrastructure code in Git gives you everything you get with application code:

- **History** — who changed what, when, and why (from commit messages)
- **Branching** — work on a new environment in isolation before merging
- **Code review** — infrastructure changes get reviewed before they're applied
- **Rollback** — if an apply breaks something, revert the commit and re-apply
- **CI/CD integration** — pipelines can run `terraform plan` on every PR and `terraform apply` on merge to main

This is the foundation of **GitOps** — the practice of using Git as the single source of truth for both application and infrastructure.

## 1.3 Infrastructure Orchestration vs Configuration Management

Two different categories of IaC tool exist. Knowing the difference matters for interviews.

**Infrastructure Orchestration** — *creating and managing the infrastructure itself*. Spinning up VMs, creating networks, provisioning databases. The infrastructure is the target.

Examples: **Terraform**, AWS CloudFormation, Pulumi.

**Configuration Management** — *configuring the software on existing infrastructure*. Installing packages, managing config files, ensuring a service is running on machines that already exist.

Examples: **Ansible**, Chef, Puppet, SaltStack.

| | Infrastructure Orchestration | Configuration Management |
|---|---|---|
| **What it manages** | The infrastructure (VMs, networks, databases) | Software on existing infrastructure |
| **Examples** | Terraform, CloudFormation, Pulumi | Ansible, Chef, Puppet |
| **Question it answers** | "What infrastructure exists?" | "What's installed and configured on it?" |
| **State tracking** | Yes — tracks what it created | Generally stateless (idempotent runs) |

In practice, many teams use both: Terraform to provision the infrastructure, Ansible to configure it. Or Terraform to provision + User Data / cloud-init for basic configuration.

---

# Chapter 2 — What is Terraform?

## 2.1 Terraform Overview

**Terraform** is an open-source IaC tool created by **HashiCorp** in 2014. It lets you define infrastructure in a high-level configuration language called **HCL (HashiCorp Configuration Language)** and then create, update, and destroy that infrastructure with a series of simple commands.

What makes Terraform special:

- **Cloud-agnostic** — works with AWS, GCP, Azure, Kubernetes, GitHub, Cloudflare, and hundreds of other providers. You write Terraform and it talks to any of them.
- **Declarative** — you describe the *desired state* of your infrastructure ("I want 3 EC2 instances"), not the steps to get there ("run this command, then this command"). Terraform figures out what to do.
- **State-aware** — Terraform tracks what it has created in a state file. This lets it know what already exists, what needs to change, and what needs to be destroyed.
- **Idempotent** — run the same configuration ten times and you get the same result. Terraform only makes changes when the real infrastructure differs from the desired state.

> **Analogy:** Terraform is like an architect's blueprint for your infrastructure. You draw the blueprint (write the `.tf` files), hand it to Terraform, and it builds exactly what's on the blueprint. If you update the blueprint, Terraform figures out the minimum changes needed to bring the building in line with the new design.

## 2.2 Tips for Using Terraform

Before writing a single line, a few habits that will save you pain:

**Always run `plan` before `apply`.** Never apply without reviewing the plan output first. It shows exactly what will be created, changed, or destroyed. Treat it like a code review for your infrastructure.

**Use version constraints on providers.** Providers release updates that can introduce breaking changes. Pin your provider version so a surprise update doesn't break your infrastructure.

**Commit your `.tf` files, never your state file.** The state file can contain sensitive data (passwords, keys). Add `terraform.tfstate` and `terraform.tfstate.backup` to `.gitignore`. Use remote state (S3) instead.

**Use remote state for anything collaborative.** Local state is fine for learning. The moment a second person touches the same infrastructure, move to remote state with locking.

**Use modules for anything you repeat.** If you're copy-pasting a resource block, it's time for a module.

---

# Chapter 3 — Installation

## 3.1 macOS (via Homebrew)

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform -version
# Terraform v1.7.0
```

## 3.2 Ubuntu / Linux

```bash
# Add the HashiCorp GPG key and repository
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform

# Verify
terraform -version
```

## 3.3 Windows

Download the Windows binary from [developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads). Extract the `.exe` to a directory (e.g. `C:\terraform\`). Add that directory to your system's PATH environment variable. Open a new terminal and run `terraform -version`.

## 3.4 VS Code Setup

Install the **HashiCorp Terraform** extension in VS Code. It provides:
- Syntax highlighting for `.tf` files
- Auto-completion for resource arguments
- Documentation on hover
- Format on save (uses `terraform fmt`)

---

# Chapter 4 — Core Concepts: State

## 4.1 What is the Terraform State File?

The **state file** (`terraform.tfstate`) is Terraform's record of what it has created. It maps your configuration to real-world resources — linking `resource "aws_instance" "web"` in your code to a specific EC2 instance ID (`i-0abc123def456789`) in AWS.

Without the state file, Terraform would have no memory. Every `apply` would try to create everything from scratch, duplicating resources.

> **Analogy:** The state file is like an inventory list of your warehouse. When you ask Terraform "do we have 3 EC2 instances?", it checks the inventory list, then checks the warehouse (AWS), and reconciles the two.

**What the state file contains:**
- Resource type and name from your configuration
- The real-world resource ID (EC2 instance ID, S3 bucket name, etc.)
- All the attributes of the resource (instance type, AMI, tags, etc.)
- Dependency information (which resources depend on which others)

```json
{
  "version": 4,
  "terraform_version": "1.7.0",
  "resources": [
    {
      "type": "aws_instance",
      "name": "web",
      "instances": [
        {
          "attributes": {
            "id": "i-0abc123def456789",
            "instance_type": "t3.micro",
            "ami": "ami-0c02fb55956c7d316"
          }
        }
      ]
    }
  ]
}
```

## 4.2 Desired State vs Current State

This is how Terraform decides what to do on every `plan` and `apply`:

**Desired state** = your `.tf` configuration files. What you *want* the infrastructure to look like.

**Current state** = the state file. What Terraform *believes* exists right now.

**Real state** = what actually exists in AWS.

Terraform reconciles these:

```
Desired state (.tf files)
        ↓
   terraform plan
        ↓
Compared with current state (state file)
        ↓
Output: what will be created (+), changed (~), or destroyed (-)
        ↓
   terraform apply
        ↓
Real AWS infrastructure updated to match desired state
State file updated to reflect new real state
```

**Idempotency:** Run `terraform apply` when nothing has changed → Terraform reports "No changes. Your infrastructure matches the configuration." Nothing happens. Run it a hundred times, same result.

## 4.3 Local State Files

By default, Terraform stores state locally in `terraform.tfstate` in your project directory.

**Good for:**
- Learning and experimentation
- Single-person projects
- Demos and quick tests

**Problems:**
- **Not shareable** — if two people apply simultaneously, state corruption
- **No locking** — nothing prevents two applies running at once
- **No backup** — if the file is deleted or corrupted, you lose the mapping to real resources
- **Security risk** — state files can contain secrets. Don't commit them to Git.

```bash
# Add to .gitignore
echo "terraform.tfstate" >> .gitignore
echo "terraform.tfstate.backup" >> .gitignore
echo ".terraform/" >> .gitignore
```

## 4.4 Remote State Files

Remote state stores `terraform.tfstate` in a central location accessible by your whole team.

**Benefits:**
- **Shared** — everyone on the team reads and writes the same state
- **Locking** — only one apply can run at a time (prevents corruption)
- **Backup** — S3 versioning keeps history of every state change
- **Security** — encrypt state at rest (S3 SSE) and in transit (HTTPS)

**AWS S3 + DynamoDB is the standard remote backend:**

```hcl
# backend.tf

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true                        # encrypt state at rest
    dynamodb_table = "terraform-state-lock"      # table for state locking
  }
}
```

**Set up the S3 bucket and DynamoDB table first** (these are created manually or with a separate "bootstrap" Terraform config — you can't use the same backend to create its own backend):

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-2
```

**Migrate from local to remote state:**

```bash
# Add the backend block to your config, then:
terraform init
# Terraform detects the new backend and asks:
# "Do you want to copy existing state to the new backend?" → yes
```

## 4.5 State Locking

When Terraform runs an apply, it **locks the state file** so no other apply can run simultaneously. Without locking, two simultaneous applies could both read the same state, both make changes, and one would overwrite the other's state file — leaving it corrupted and out of sync with reality.

With S3 + DynamoDB: Terraform writes a lock entry to the DynamoDB table at the start of an apply. Any other apply attempt reads the table, finds the lock, and refuses to proceed until the lock is released.

```
Apply 1 starts → writes lock to DynamoDB → makes changes → releases lock
Apply 2 starts while 1 is running → reads DynamoDB → finds lock → waits/errors
```

---

# Chapter 5 — Core Workflow

## 5.1 The Five Commands You'll Use Every Day

```
terraform init     → initialise the working directory
terraform validate → check syntax
terraform plan     → preview changes
terraform apply    → make changes
terraform destroy  → tear everything down
```

## 5.2 `terraform init`

Initialises a Terraform working directory. Must be run first in any new directory and after adding/changing providers or backends.

What it does:
- Downloads the provider plugins specified in your configuration
- Sets up the backend (local or remote)
- Creates the `.terraform/` directory

```bash
terraform init

# Output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 5.0"...
# - Installing hashicorp/aws v5.31.0...
# Terraform has been successfully initialized!
```

```bash
# Upgrade providers to latest allowed version
terraform init -upgrade

# Re-run after adding a new backend
terraform init -reconfigure
```

## 5.3 `terraform validate`

Checks that your configuration files are syntactically valid and internally consistent. Does not access any remote APIs — purely a local check.

```bash
terraform validate

# Success:
# Success! The configuration is valid.

# Error:
# Error: Unsupported argument
# on main.tf line 5, in resource "aws_instance" "web":
#   5: instnce_type = "t3.micro"
# An argument named "instnce_type" is not expected here.
```

Run this before `plan`. Catches typos and missing required arguments without hitting AWS.

## 5.4 `terraform plan`

Previews exactly what Terraform will do when you apply. It compares desired state (`.tf` files) with current state (state file) and shows the diff.

```bash
terraform plan

# Output format:
# + create    (green plus — new resource)
# ~ update    (yellow tilde — resource will be modified in-place)
# - destroy   (red minus — resource will be deleted)
# -/+ replace (resource will be destroyed and recreated)

# Example:
# Terraform will perform the following actions:
#
#   # aws_instance.web will be created
#   + resource "aws_instance" "web" {
#       + ami           = "ami-0c02fb55956c7d316"
#       + instance_type = "t3.micro"
#       + id            = (known after apply)
#     }
#
# Plan: 1 to add, 0 to change, 0 to destroy.
```

```bash
# Save plan to a file (apply this exact plan later — no changes between plan and apply)
terraform plan -out=tfplan

# Apply the saved plan
terraform apply tfplan

# Useful in CI/CD: plan in the PR, apply the saved plan after approval
```

## 5.5 `terraform apply`

Executes the changes shown in the plan. Prompts for confirmation by default.

```bash
terraform apply

# Shows plan output, then:
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
# Enter a value: yes

# Skip the confirmation prompt (for automation/CI)
terraform apply -auto-approve
```

After apply:
- Real AWS resources are created/updated/destroyed
- State file is updated to reflect the new state
- Outputs are printed

## 5.6 `terraform destroy`

Destroys all resources managed by the current configuration. The reverse of apply.

```bash
terraform destroy

# Shows what will be destroyed, then:
# Do you really want to destroy all resources?
#   Terraform will destroy all your managed infrastructure, as shown above.
#   There is no undo. Only 'yes' will be accepted to confirm.
# Enter a value: yes

# Auto-approve (use with extreme care)
terraform destroy -auto-approve

# Destroy only a specific resource
terraform destroy -target=aws_instance.web
```

> **Critical:** `terraform destroy` deletes real infrastructure including databases and their data. Double-check you're in the right workspace and directory before running it.

---

# Chapter 6 — Providers and Resources

## 6.1 What is a Provider?

A **provider** is a plugin that lets Terraform communicate with an external API. The AWS provider knows how to talk to the AWS API to create EC2 instances, S3 buckets, VPCs, and everything else. Without a provider, Terraform is just a language — it can't do anything.

Terraform has providers for hundreds of platforms: AWS, GCP, Azure, Kubernetes, GitHub, Cloudflare, Datadog, PagerDuty, and more.

**Provider configuration:**

```hcl
# provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"           # ~> means >= 5.0 and < 6.0
    }
  }

  required_version = ">= 1.5.0"   # minimum Terraform version
}

provider "aws" {
  region = "eu-west-2"
}
```

**Version constraints explained:**

| Constraint | Meaning |
|---|---|
| `= 5.0.0` | Exactly 5.0.0 only |
| `!= 5.0.0` | Any version except 5.0.0 |
| `>= 5.0.0` | 5.0.0 or higher |
| `<= 5.0.0` | 5.0.0 or lower |
| `~> 5.0` | >= 5.0, < 6.0 (allow patch updates) |
| `~> 5.0.0` | >= 5.0.0, < 5.1.0 (allow only bug fixes) |

## 6.2 AWS Credentials for Terraform

Terraform needs AWS credentials to create resources. Several ways to provide them:

**Option 1: Environment variables (recommended for CI/CD)**

```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="eu-west-2"

terraform apply
```

**Option 2: AWS CLI configured profile (recommended for local development)**

```bash
# If you've already run 'aws configure', Terraform uses those credentials automatically
aws configure

# Use a named profile
provider "aws" {
  region  = "eu-west-2"
  profile = "my-work-profile"
}
```

**Option 3: IAM role (recommended for EC2 or CI/CD systems)**

If Terraform runs on an EC2 instance or in ECS, attach an IAM role. Terraform automatically picks up the instance profile credentials. No access keys needed anywhere.

> **Never hardcode access keys in `.tf` files.** They will end up in Git and be compromised.

## 6.3 Resource Blocks

A **resource block** declares a piece of infrastructure you want Terraform to create and manage.

```hcl
resource "<PROVIDER>_<TYPE>" "<LOCAL_NAME>" {
  # arguments
}
```

- `<PROVIDER>_<TYPE>` — the resource type: `aws_instance`, `aws_s3_bucket`, `aws_vpc`
- `<LOCAL_NAME>` — your name for this resource within the Terraform configuration. Used to reference this resource elsewhere.

**Real example:**

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  tags = {
    Name        = "web-server"
    Environment = "production"
  }
}
```

Reference this resource elsewhere: `aws_instance.web_server.id`, `aws_instance.web_server.public_ip`

## 6.4 The Terraform Registry

**registry.terraform.io** is the official registry for providers and modules. For every resource you want to create, this is your first stop.

For each resource type you'll find:
- **Argument Reference** — all possible configuration arguments (required and optional)
- **Attribute Reference** — values you can read from the resource after it's created (ID, ARN, etc.)
- **Example Usage** — working code examples to start from

> **Workflow:** Search the registry for the resource you need → copy the example → check the argument reference for the arguments your specific use case needs → adjust and apply.

---

# Chapter 7 — Building an EC2 Instance: Complete Demo

This is the full workflow from nothing to a running EC2 instance in AWS.

## 7.1 Project structure

```
my-terraform-project/
├── provider.tf       # provider and Terraform settings
├── main.tf           # resources
├── variables.tf      # variable declarations
├── outputs.tf        # outputs
├── terraform.tfvars  # variable values (don't commit secrets)
└── .gitignore        # exclude .terraform/, tfstate files
```

## 7.2 `provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-2"
}
```

## 7.3 `main.tf` — EC2 with Security Group

```hcl
# Security group allowing SSH and HTTP
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # restrict to your IP in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

# EC2 instance
resource "aws_instance" "web_server" {
  ami                    = "ami-0c02fb55956c7d316"   # Amazon Linux 2023 in eu-west-2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "web-server"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## 7.4 Run it

```bash
# Step 1: Initialise
terraform init

# Step 2: Validate syntax
terraform validate

# Step 3: Preview
terraform plan
# Read every line. Verify what will be created.

# Step 4: Apply
terraform apply
# Type 'yes' when prompted

# Step 5: Verify
# Check AWS console — EC2 instance appears
# curl http://PUBLIC_IP → "Hello from Terraform!"

# Step 6: When done — clean up
terraform destroy
```

**Find the AMI ID for your region:**

```bash
# Get the latest Amazon Linux 2023 AMI for eu-west-2
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023*-x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --region eu-west-2
```

---

# Chapter 8 — Importing Existing Resources

## 8.1 What is `terraform import`?

If you created infrastructure manually (clicked through the console, ran CLI commands) before using Terraform, you can **import** it into Terraform management without destroying and recreating it.

**Why import?**
- You have existing infrastructure you want to start managing as code
- A colleague created something manually and you want to bring it under IaC control
- You want to generate Terraform code that matches existing resources

## 8.2 The Import Workflow

```bash
# The general syntax
terraform import <resource_type>.<local_name> <real_resource_id>

# Import an EC2 instance
terraform import aws_instance.web i-0abc123def456789

# Import an S3 bucket
terraform import aws_s3_bucket.my_bucket my-bucket-name

# Import a security group
terraform import aws_security_group.web_sg sg-0abc123def456789

# Import a VPC
terraform import aws_vpc.main vpc-0abc123def456789
```

**Steps:**

1. **Create the resource block in your `.tf` file first.** Terraform needs a block to import into.

```hcl
resource "aws_instance" "web" {
  # leave arguments empty initially
}
```

2. **Run the import command.**

```bash
terraform import aws_instance.web i-0abc123def456789
# State file now contains the real resource's data
```

3. **Run `terraform plan` to see the drift.**

```bash
terraform plan
# Shows what differences exist between your empty block and the real resource
# ~ update: instance_type = "t2.micro" → null (missing from your config)
```

4. **Fill in the resource block to match the real resource.**

```bash
terraform state show aws_instance.web
# Shows all attributes of the imported resource
# Copy the relevant ones into your resource block
```

5. **Run `terraform plan` again until it shows "No changes".**

When `plan` shows no changes, your Terraform configuration perfectly matches the real resource. It's now fully under Terraform management.

## 8.3 Using the Registry for Import

For each resource type on registry.terraform.io, there's an **Import** section showing the exact import syntax and what ID to use.

Example for `aws_instance`:
```
terraform import aws_instance.example i-12345678
```
Where `i-12345678` is the instance ID from the EC2 console or `aws ec2 describe-instances`.

## 8.4 State Commands

```bash
# List all resources tracked in state
terraform state list

# Show full details of a specific resource in state
terraform state show aws_instance.web

# Move a resource to a different name (rename without destroy/recreate)
terraform state mv aws_instance.old_name aws_instance.new_name

# Remove a resource from state without destroying it
# (use when you want Terraform to forget about something it manages, without deleting it)
terraform state rm aws_instance.web
```

---

# Chapter 9 — Variables

## 9.1 Why Variables?

Without variables, your Terraform code is hardcoded. Every value is fixed. Change the region and you're editing 15 files. Use different instance types for dev and prod? Copy-paste the whole configuration and change values manually. That breaks the DRY principle immediately.

Variables make your configuration **dynamic** and **reusable**.

## 9.2 Input Variables

**Input variables** accept values from the outside — from the CLI, from `.tfvars` files, or from CI/CD environments.

```hcl
# variables.tf

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  # No default — Terraform will prompt if not provided
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to create"
  default     = 1
}

variable "enable_public_ip" {
  type        = bool
  description = "Whether to assign a public IP"
  default     = true
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access the web server"
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    ManagedBy = "Terraform"
  }
}
```

**Reference in your resources:**

```hcl
resource "aws_instance" "web" {
  instance_type          = var.instance_type
  associate_public_ip    = var.enable_public_ip
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}
```

## 9.3 Providing Variable Values

**Method 1: `terraform.tfvars` file (most common)**

```hcl
# terraform.tfvars
instance_type    = "t3.small"
environment      = "production"
instance_count   = 3
enable_public_ip = false
allowed_cidrs    = ["10.0.0.0/8", "172.16.0.0/12"]
tags = {
  ManagedBy = "Terraform"
  Team      = "Platform"
  CostCentre = "Engineering"
}
```

Terraform automatically loads `terraform.tfvars` and any `*.auto.tfvars` files.

**Method 2: Named `.tfvars` file (for multiple environments)**

```bash
# dev.tfvars
instance_type = "t3.micro"
environment   = "dev"

# prod.tfvars
instance_type = "m5.large"
environment   = "prod"

# Apply with specific var file
terraform apply -var-file="prod.tfvars"
```

**Method 3: Command-line flags**

```bash
terraform apply -var="instance_type=t3.small" -var="environment=staging"
```

**Method 4: Environment variables**

```bash
export TF_VAR_instance_type="t3.small"
export TF_VAR_environment="production"
terraform apply
```

## 9.4 Variable Hierarchy (Priority Order)

When the same variable is provided in multiple places, this is the priority (highest wins):

```
1. Command-line flags     (-var="key=value")          HIGHEST
2. Environment variables  (TF_VAR_key)
3. .tfvars files          (terraform.tfvars, *.auto.tfvars, -var-file)
4. Default value          (in variable block)           LOWEST
```

**Practical example:**

```bash
# variable has default = "t3.micro"
# terraform.tfvars sets instance_type = "t3.small"
# You run:
terraform apply -var="instance_type=m5.large"

# Result: m5.large wins (command-line overrides everything)
```

## 9.5 Local Variables

**Local variables** are computed within your configuration — not provided by the user. Use them to avoid repeating complex expressions.

```hcl
# In any .tf file (often main.tf or locals.tf)

locals {
  # Simple values
  common_prefix = "myapp-${var.environment}"

  # Computed from other variables
  instance_ami = var.environment == "prod" ? "ami-0abc123" : "ami-0def456"

  # Maps used repeatedly
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "myapp"
    Owner       = "platform-team"
  }
}

# Reference with local. prefix
resource "aws_instance" "web" {
  ami  = local.instance_ami
  tags = local.common_tags
}

resource "aws_s3_bucket" "data" {
  bucket = "${local.common_prefix}-data"
  tags   = local.common_tags
}
```

## 9.6 Output Variables

**Output variables** expose specific values after an apply — to the terminal, to other Terraform configurations (root module using a child module), or to CI/CD pipelines.

```hcl
# outputs.tf

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "URL of the web server"
  value       = "http://${aws_instance.web.public_ip}"
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web_sg.id
}

# Sensitive output — value is hidden in terminal but still stored in state
output "db_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true
}
```

```bash
# After apply, outputs are printed automatically
# View outputs at any time:
terraform output
terraform output public_ip

# Output as JSON (useful in scripts)
terraform output -json
```

## 9.7 Variable Types

| Type | Example | Use |
|---|---|---|
| `string` | `"t3.micro"` | Single text value |
| `number` | `3` | Numeric value |
| `bool` | `true` | True/false flag |
| `list(string)` | `["10.0.0.0/8", "172.16.0.0/12"]` | Ordered list of strings |
| `map(string)` | `{Name = "web", Env = "prod"}` | Key-value pairs |
| `set(string)` | Like a list but unordered, no duplicates | Unique values |
| `object({...})` | Structured type with named attributes | Complex configuration |
| `any` | Any type | When type is dynamic |

**Object type example:**

```hcl
variable "server_config" {
  type = object({
    instance_type = string
    disk_size     = number
    enable_monitoring = bool
  })
  default = {
    instance_type     = "t3.micro"
    disk_size         = 20
    enable_monitoring = false
  }
}

# Reference:
resource "aws_instance" "web" {
  instance_type = var.server_config.instance_type

  root_block_device {
    volume_size = var.server_config.disk_size
  }

  monitoring = var.server_config.enable_monitoring
}
```

---

# Chapter 10 — Modules

## 10.1 What is a Module?

A **module** is a container for multiple related resources that are used together. It's a way to package and reuse Terraform configuration — the infrastructure equivalent of writing a reusable function instead of copying code everywhere.

Every Terraform configuration is a module. The directory where you run `terraform apply` is the **root module**. Modules you call from the root module are **child modules**.

**Why modules?**

- **DRY (Don't Repeat Yourself)** — define your EC2 + security group + IAM role configuration once, use it for every service
- **Consistency** — every team uses the same approved configuration for common resources
- **Abstraction** — the caller doesn't need to know all the implementation details
- **Easier collaboration** — teams can publish and share modules
- **Maintainability** — fix a bug in the module once, all callers benefit

## 10.2 What Makes a Good Module?

A well-designed module:

- **Does one thing well** — an EC2 module provisions EC2 and its direct dependencies. Not a VPC.
- **Has clear inputs (variables)** — all configurable values are exposed as variables with descriptions
- **Has useful outputs** — exposes the IDs and ARNs that callers need (instance ID, security group ID)
- **Has a README** — explains what the module does, what inputs it takes, what it outputs
- **Is versioned** — use Git tags so callers can pin to a version
- **Has sensible defaults** — reduce the number of required inputs

**Signs of a bad module:**
- Does too much (provisions entire stacks instead of components)
- Hardcodes values that should be variables
- No outputs — callers can't get what they need from it
- No documentation

## 10.3 Module Structure

```
modules/
└── ec2/
    ├── main.tf         # resources
    ├── variables.tf    # input variables
    ├── outputs.tf      # outputs
    └── README.md       # documentation
```

**`modules/ec2/variables.tf`:**

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "allowed_ports" {
  type        = list(number)
  description = "Ports to open in the security group"
  default     = [80, 443]
}
```

**`modules/ec2/main.tf`:**

```hcl
resource "aws_security_group" "this" {
  name        = "${var.environment}-sg"
  description = "Security group for ${var.environment}"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name        = "${var.environment}-instance"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

**`modules/ec2/outputs.tf`:**

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}
```

## 10.4 Calling a Module

**`main.tf` (root module):**

```hcl
# Call the module once for dev
module "dev_server" {
  source = "./modules/ec2"

  ami_id        = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  environment   = "dev"
  allowed_ports = [80, 443, 22]
}

# Call the same module for prod with different inputs
module "prod_server" {
  source = "./modules/ec2"

  ami_id        = "ami-0c02fb55956c7d316"
  instance_type = "m5.large"
  environment   = "prod"
  allowed_ports = [80, 443]
}

# Reference module outputs
output "dev_public_ip" {
  value = module.dev_server.public_ip
}

output "prod_public_ip" {
  value = module.prod_server.public_ip
}
```

```bash
# After adding a new module, init is required to download module dependencies
terraform init

terraform plan
terraform apply
```

## 10.5 Module Sources

Modules can come from different sources:

```hcl
# Local path (in the same repo)
module "ec2" {
  source = "./modules/ec2"
}

# Terraform Registry (public modules)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  # ...
}

# GitHub repository
module "ec2" {
  source = "git::https://github.com/myorg/terraform-modules.git//modules/ec2?ref=v1.2.0"
}

# S3 bucket
module "ec2" {
  source = "s3::https://s3.eu-west-2.amazonaws.com/my-terraform-modules/ec2.zip"
}
```

---

# Chapter 11 — Advanced Terraform

## 11.1 LocalStack — Test Without AWS Costs

**LocalStack** is a local mock of AWS services. You can run Terraform configurations against it without hitting real AWS — no costs, no cleanup, instant feedback.

```bash
# Install LocalStack
pip install localstack

# Start LocalStack
localstack start

# Configure Terraform to use LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}
```

Useful for: testing module logic, validating configurations, learning Terraform without incurring AWS charges.

## 11.2 The `count` Argument

Create multiple copies of a resource without repeating the block:

```hcl
# Create 3 EC2 instances
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  tags = {
    Name = "web-server-${count.index}"   # web-server-0, web-server-1, web-server-2
  }
}

# Reference specific instances
output "first_instance_id" {
  value = aws_instance.web[0].id
}

# Reference all instances
output "all_instance_ids" {
  value = aws_instance.web[*].id
}

# Conditional creation — create only in prod
resource "aws_instance" "monitoring" {
  count         = var.environment == "prod" ? 1 : 0
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.small"
}
```

## 11.3 `for_each` — Better Than `count` for Maps and Sets

`count` uses numeric indices. If you delete the middle item, all indices shift and Terraform recreates resources. `for_each` uses unique keys — deletions don't affect other resources.

```hcl
# Create instances for a map of configurations
variable "servers" {
  type = map(object({
    instance_type = string
    environment   = string
  }))
  default = {
    web = {
      instance_type = "t3.micro"
      environment   = "prod"
    }
    api = {
      instance_type = "t3.small"
      environment   = "prod"
    }
    worker = {
      instance_type = "t3.medium"
      environment   = "prod"
    }
  }
}

resource "aws_instance" "servers" {
  for_each = var.servers

  ami           = "ami-0c02fb55956c7d316"
  instance_type = each.value.instance_type

  tags = {
    Name        = each.key                  # "web", "api", "worker"
    Environment = each.value.environment
  }
}

# Reference a specific server
output "web_server_ip" {
  value = aws_instance.servers["web"].public_ip
}

# For_each over a set of strings
resource "aws_iam_user" "devs" {
  for_each = toset(["alice", "bob", "carol"])
  name     = each.key
}
```

## 11.4 Conditionals

```hcl
# Ternary operator: condition ? true_value : false_value
resource "aws_instance" "web" {
  instance_type = var.environment == "prod" ? "m5.large" : "t3.micro"
  monitoring    = var.environment == "prod" ? true : false
}

# Conditional resource creation with count
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_monitoring ? 1 : 0
  # ... alarm config
}

# Conditional string
locals {
  bucket_name = var.environment == "prod" ? "myapp-prod-data" : "myapp-dev-data"
}
```

## 11.5 `coalesce` — Default Values

`coalesce` returns the first non-empty value in a list. Useful for providing fallbacks:

```hcl
locals {
  # Use var.custom_name if set, otherwise fall back to a generated name
  instance_name = coalesce(var.custom_name, "default-instance-${var.environment}")

  # First non-empty AMI ID
  ami = coalesce(var.custom_ami, data.aws_ami.latest.id)
}
```

## 11.6 Merging Variables

`merge()` combines maps. Later maps override earlier ones for duplicate keys:

```hcl
locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Project     = "myapp"
    CostCentre  = "engineering"
  }

  environment_tags = {
    Environment = var.environment
    Owner       = var.team_name
  }

  # Merge — environment_tags overrides default_tags on key conflicts
  all_tags = merge(local.default_tags, local.environment_tags)
}

resource "aws_instance" "web" {
  # ...
  tags = merge(local.all_tags, { Name = "web-server" })
}
```

## 11.7 String Concatenation and `concat()`

```hcl
# String interpolation
locals {
  bucket_name = "${var.project}-${var.environment}-${var.region}-data"
}

# concat() for lists
variable "base_cidrs" {
  default = ["10.0.0.0/8"]
}
variable "extra_cidrs" {
  default = ["172.16.0.0/12"]
}

locals {
  all_cidrs = concat(var.base_cidrs, var.extra_cidrs)
  # ["10.0.0.0/8", "172.16.0.0/12"]
}
```

## 11.8 Dynamic Blocks

`dynamic` blocks let you generate repeated nested blocks based on a variable — avoiding copy-paste of identical blocks:

```hcl
# Without dynamic blocks — repetitive:
resource "aws_security_group" "web" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

# With dynamic blocks — clean and variable-driven:
variable "ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { port = 22,  protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] }
  ]
}

resource "aws_security_group" "web" {
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## 11.9 Template Files

For complex strings (like User Data scripts or config files), use `templatefile()`:

```bash
# scripts/user_data.sh.tpl
#!/bin/bash
echo "Environment: ${environment}"
echo "App version: ${app_version}"
yum install -y ${package_name}
```

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  user_data = templatefile("${path.module}/scripts/user_data.sh.tpl", {
    environment  = var.environment
    app_version  = var.app_version
    package_name = "httpd"
  })
}
```

## 11.10 Working with JSON

```hcl
# Encode a map as JSON (for IAM policies)
resource "aws_iam_policy" "s3_read" {
  name   = "s3-read-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
      }
    ]
  })
}

# Decode JSON from a file
locals {
  config = jsondecode(file("${path.module}/config.json"))
}
```

## 11.11 String Functions

```hcl
locals {
  # Case conversion
  upper_env = upper(var.environment)     # "PROD"
  lower_env = lower(var.environment)     # "prod"

  # String operations
  trimmed    = trimspace("  hello  ")    # "hello"
  replaced   = replace("hello-world", "-", "_")  # "hello_world"

  # List/map operations
  sorted     = sort(["banana", "apple", "cherry"])  # ["apple", "banana", "cherry"]
  sliced     = slice(["a", "b", "c", "d"], 1, 3)    # ["b", "c"]

  # Range
  port_range = range(8000, 8010)        # [8000, 8001, ..., 8009]
}
```

## 11.12 The `can` Function

`can()` evaluates an expression and returns `true` if it succeeds, `false` if it errors. Useful for conditional logic where a value might not exist:

```hcl
variable "config" {
  type    = map(string)
  default = {}
}

locals {
  # Returns true if config["endpoint"] exists and is a valid string, false otherwise
  has_endpoint = can(var.config["endpoint"])

  # Use can() to safely access optional nested values
  endpoint = can(var.config["endpoint"]) ? var.config["endpoint"] : "https://default.example.com"
}
```

## 11.13 For Expressions — Creating Complex Resources

`for` expressions transform one collection into another:

```hcl
variable "instance_names" {
  default = ["web", "api", "worker"]
}

locals {
  # Create a map from a list: { "web" = "web-prod", "api" = "api-prod", ... }
  name_map = {
    for name in var.instance_names :
    name => "${name}-${var.environment}"
  }

  # Filter a list
  prod_instances = [
    for instance in var.instances :
    instance if instance.environment == "prod"
  ]

  # Transform list to uppercase
  upper_names = [for name in var.instance_names : upper(name)]
}
```

---

# Chapter 12 — Terraform Workflow in CI/CD

## 12.1 Terraform in a GitHub Actions Pipeline

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

permissions:
  id-token: write   # for OIDC auth with AWS
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "~> 1.7"

      - name: Configure AWS credentials (OIDC — no stored keys)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-terraform
          aws-region: eu-west-2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        # On PRs: shows what will change so reviewers can see it

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply tfplan
        # Only apply when merging to main — not on PRs
```

This pipeline:
- Runs `plan` on every PR — reviewers see the infrastructure diff alongside the code diff
- Runs `apply` only when merging to main — your infrastructure deploys automatically
- Uses OIDC (no stored AWS access keys in GitHub secrets)

---

# Chapter 13 — Terraform Interview Questions

From the course's dedicated interview prep section — these are the questions you'll face.

**1. What is Terraform and what problem does it solve?**
An open-source IaC tool by HashiCorp that lets you define infrastructure in declarative configuration files. Solves the problem of inconsistent, manual, undocumented infrastructure by making it reproducible, versionable, and automatable.

**2. What is the difference between declarative and imperative IaC?**
Declarative (Terraform): you describe the desired end state. Terraform figures out how to get there. Imperative (scripts): you write step-by-step instructions for how to reach the state. Declarative is safer because running it twice is safe — Terraform only changes what differs.

**3. What is the Terraform state file and why is it important?**
The state file (`terraform.tfstate`) maps your configuration to real-world resources. Without it, Terraform can't know what it has created. It enables Terraform to detect drift between your configuration and real infrastructure, and to destroy resources it created.

**4. What is state locking and why does it matter?**
State locking prevents two applies from running simultaneously, which would corrupt the state file. With S3 + DynamoDB as the backend, Terraform writes a lock to DynamoDB at the start of an apply and releases it when done.

**5. What is the difference between local and remote state?**
Local state is stored in `terraform.tfstate` on your machine — simple, but not shareable or locked. Remote state (S3 + DynamoDB) is stored centrally, supports team collaboration, provides locking, and enables encryption and versioning.

**6. Walk me through the core Terraform workflow.**
`terraform init` (download providers, set up backend) → `terraform validate` (syntax check) → `terraform plan` (preview changes) → `terraform apply` (execute changes) → `terraform destroy` (tear down when done).

**7. What is a provider?**
A plugin that enables Terraform to interact with an external API. The AWS provider knows how to call AWS APIs to create EC2 instances, VPCs, etc. Configured with source and version, downloaded by `terraform init`.

**8. What is a module?**
A container for related resources used together. Enables reusability — define EC2 + security group + IAM once, call it in many places with different inputs. Every Terraform directory is a module; modules called from main.tf are child modules.

**9. What is the difference between `count` and `for_each`?**
`count` creates resources by index (0, 1, 2...). If you delete the middle item, indices shift and Terraform recreates many resources unnecessarily. `for_each` uses unique string keys — deleting one item only affects that item.

**10. What are the three types of variables in Terraform?**
Input variables (user-provided, via `.tfvars` or CLI), local variables (computed within the configuration), and output variables (expose values after apply, to the terminal or to other modules).

**11. What is the variable priority order?**
Command-line flags → environment variables (`TF_VAR_*`) → `.tfvars` files → default values.

**12. What is `terraform import` and when do you use it?**
Brings existing infrastructure under Terraform management without destroying and recreating it. Used when infrastructure was created manually before IaC was adopted. Steps: create a matching resource block → run `terraform import` → run `terraform plan` → fill in config until plan shows no changes.

**13. How do you handle secrets in Terraform?**
Never hardcode secrets in `.tf` files. Use: environment variables for access keys, AWS Secrets Manager or Parameter Store for runtime secrets (reference via `data` source), `sensitive = true` on output variables containing secrets, and remote state with encryption for state files.

**14. What is a dynamic block?**
A way to generate repeated nested configuration blocks from a variable. Instead of copy-pasting identical `ingress` blocks in a security group, use `dynamic "ingress" { for_each = var.ingress_rules ... }` to generate them programmatically.

**15. How does Terraform handle dependencies between resources?**
Explicitly: `depends_on = [aws_instance.web]` forces a dependency. Implicitly: when one resource references another's attribute (`vpc_security_group_ids = [aws_security_group.web_sg.id]`), Terraform automatically knows to create the security group first.

---

# Chapter 14 — Quick Reference Cheat Sheet

## Core Commands

```bash
terraform init           # initialise, download providers
terraform init -upgrade  # upgrade providers to latest allowed
terraform validate       # check syntax (no API calls)
terraform fmt            # format .tf files
terraform plan           # preview changes
terraform plan -out=tfplan  # save plan for later apply
terraform apply          # make changes (with confirmation)
terraform apply -auto-approve  # skip confirmation (CI/CD)
terraform apply tfplan   # apply a saved plan
terraform destroy        # destroy all resources
terraform destroy -target=aws_instance.web  # destroy one resource
terraform output         # show output values
terraform output -json   # outputs as JSON
terraform state list     # list resources in state
terraform state show <resource>  # show resource details
terraform state mv       # rename a resource in state
terraform state rm       # remove resource from state (without deleting)
terraform import <type>.<name> <id>  # import existing resource
```

## File Structure

```
project/
├── provider.tf       # terraform{} and provider{} blocks
├── main.tf           # resource blocks
├── variables.tf      # variable declarations
├── outputs.tf        # output declarations
├── locals.tf         # local variable declarations (optional)
├── terraform.tfvars  # variable values (don't commit secrets)
├── backend.tf        # remote state config (optional, can be in provider.tf)
└── .gitignore        # .terraform/, *.tfstate, *.tfstate.backup, *.tfvars (if secrets)
```

## Provider Block

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-2"
}
```

## Remote State (S3 Backend)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Variables

```hcl
# Declaration
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

# Reference
var.instance_type

# Local variable
locals {
  name = "${var.environment}-server"
}
local.name

# Output
output "instance_id" {
  value = aws_instance.web.id
}
```

## Resource Block

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags          = local.common_tags
}
```

## Module Call

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
  environment   = "prod"
}

# Reference module outputs
module.ec2.instance_id
module.ec2.public_ip
```

## Advanced Patterns

```hcl
# count
resource "aws_instance" "web" {
  count         = 3
  instance_type = "t3.micro"
  tags          = { Name = "web-${count.index}" }
}
aws_instance.web[0].id

# for_each
resource "aws_instance" "servers" {
  for_each      = var.servers_map
  instance_type = each.value.instance_type
  tags          = { Name = each.key }
}
aws_instance.servers["web"].id

# conditional
instance_type = var.environment == "prod" ? "m5.large" : "t3.micro"

# dynamic block
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port   = ingress.value.port
    to_port     = ingress.value.port
    protocol    = "tcp"
    cidr_blocks = ingress.value.cidr_blocks
  }
}

# for expression
locals {
  names = [for name in var.list : upper(name)]
  map   = { for k, v in var.map : k => "${v}-${var.env}" }
}
```

## Variable Priority (highest → lowest)

```
1. -var flag on CLI
2. TF_VAR_ environment variables
3. terraform.tfvars / *.auto.tfvars / -var-file
4. default value in variable block
```

---

# Chapter 15 — Terragrunt: Terraform at Scale

## 15.1 What is Terragrunt?

**Terragrunt** is a thin wrapper around Terraform that adds features for managing Terraform at scale across multiple environments, accounts, and regions. It's maintained by Gruntwork and widely used in large organisations.

The problems Terragrunt solves:

| Problem | Terragrunt solution |
|---|---|
| Repeating backend config in every module | Define it once in a root `terragrunt.hcl` |
| Running `terraform apply` across many modules | `terragrunt run-all apply` |
| Managing multiple environments (dev/staging/prod) | Folder structure + `inputs = {}` per environment |
| Keeping modules DRY across environments | Inheritance from parent `terragrunt.hcl` |

## 15.2 Terragrunt Project Structure

```
infrastructure/
├── terragrunt.hcl              # root config (backend, provider defaults)
├── dev/
│   ├── terragrunt.hcl          # dev-specific inputs
│   ├── vpc/
│   │   └── terragrunt.hcl
│   ├── ec2/
│   │   └── terragrunt.hcl
│   └── rds/
│       └── terragrunt.hcl
├── staging/
│   ├── terragrunt.hcl
│   └── ...
└── prod/
    ├── terragrunt.hcl
    └── ...
```

## 15.3 Root `terragrunt.hcl`

```hcl
# infrastructure/terragrunt.hcl

# Generate backend config dynamically for every child module
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "my-terraform-state-${local.account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Generate provider config for every child
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

locals {
  aws_region = "eu-west-2"
  account_id = get_aws_account_id()
}
```

## 15.4 Environment-Level `terragrunt.hcl`

```hcl
# infrastructure/dev/terragrunt.hcl

locals {
  environment = "dev"
}

inputs = {
  environment = local.environment
}
```

## 15.5 Module-Level `terragrunt.hcl`

```hcl
# infrastructure/dev/ec2/terragrunt.hcl

terraform {
  source = "../../../modules/ec2"   # points to the shared module
}

include "root" {
  path = find_in_parent_folders()    # inherits root terragrunt.hcl settings
}

inputs = {
  instance_type = "t3.micro"
  ami_id        = "ami-0c02fb55956c7d316"
}
```

## 15.6 Terragrunt Commands

```bash
# Install Terragrunt
brew install terragrunt

# Run terraform commands via Terragrunt
terragrunt init
terragrunt plan
terragrunt apply
terragrunt destroy

# Run across ALL modules in a directory (and subdirectories)
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy

# Run for a specific module
cd infrastructure/dev/ec2
terragrunt apply
```

**When to use Terragrunt vs plain Terraform:**
- Small team, single environment → plain Terraform is enough
- Multiple environments (dev/staging/prod), multiple AWS accounts, large team → Terragrunt pays off

---

# Chapter 16 — Complete Working Example: VPC + EC2 + S3 Backend

This is a full, working Terraform configuration you can use as a starting point for your own projects. It provisions a VPC, public subnet, internet gateway, security group, and EC2 instance — all wired together correctly.

## 16.1 File: `backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-yourname"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## 16.2 File: `provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}
```

## 16.3 File: `variables.tf`

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
  default     = "ami-0c02fb55956c7d316"   # Amazon Linux 2023 eu-west-2
}
```

## 16.4 File: `locals.tf`

```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "devops-learning"
  }

  name_prefix = "${var.environment}-project"
}
```

## 16.5 File: `main.tf`

```hcl
# ── VPC ──────────────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
}

# ── Internet Gateway ──────────────────────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-igw" })
}

# ── Public Subnet ─────────────────────────────────────────────────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-subnet" })
}

# ── Route Table ───────────────────────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-rt" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── Security Group ────────────────────────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP, HTTPS and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # restrict to your IP in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-web-sg" })
}

# ── EC2 Instance ──────────────────────────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Deployed with Terraform — ${var.environment}</h1>" > /var/www/html/index.html
  EOF

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-web" })
}
```

## 16.6 File: `outputs.tf`

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web.public_ip}"
}
```

## 16.7 File: `terraform.tfvars`

```hcl
# Override defaults for your specific deployment
aws_region         = "eu-west-2"
environment        = "dev"
instance_type      = "t3.micro"
```

## 16.8 File: `.gitignore`

```
# Terraform state — never commit
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfstate
*.tfstate.*

# Crash logs
crash.log
crash.*.log

# Variable files that may contain secrets
*.tfvars
!example.tfvars   # commit example files only

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI config
.terraformrc
terraform.rc
```

## 16.9 Deploy it

```bash
# 1. Create the S3 bucket and DynamoDB table for remote state first
# (one-time setup — see Chapter 4.4)

# 2. Initialise
terraform init

# 3. Validate
terraform validate

# 4. Plan — read every line
terraform plan

# 5. Apply
terraform apply
# Type 'yes'

# 6. Test it
curl $(terraform output -raw website_url)
# <h1>Deployed with Terraform — dev</h1>

# 7. Clean up
terraform destroy
```

---

# Appendix — Being Hireable: What to Know Cold

Terraform is now explicitly required on almost every DevOps, Platform Engineer, and SRE job description. These are the things you must demonstrate fluently:

1. **Explain IaC and why it matters** — consistency, reproducibility, version control, automation, documentation-as-code. Contrast with ClickOps (manual console changes).

2. **Walk through the core workflow** — `init` → `validate` → `plan` → `apply` → `destroy`. Explain what each does. Know that `plan` doesn't change anything — it only previews.

3. **Explain the state file** — what it contains, why it's critical, why you never commit it to Git. Know that losing the state file doesn't destroy real infrastructure, but means Terraform can no longer manage it.

4. **Remote state with S3 + DynamoDB** — explain the setup, why you need both (S3 for storage, DynamoDB for locking), and how to configure the backend block.

5. **Write a provider and resource block from memory** — `terraform {}`, `required_providers {}`, `provider "aws" {}`, `resource "aws_instance" "web" {}`. Know the basic arguments.

6. **Variables — all three types** — input (user-provided, `var.name`), local (computed, `local.name`), output (exposed, print after apply). Write the declaration and reference syntax without looking it up.

7. **Variable priority order** — CLI flag → env var → `.tfvars` → default. Know this for the interview question "how would you override a variable in CI/CD?"

8. **`terraform import`** — when you'd use it (importing manually created resources), the workflow (create block, import, run plan, fill in config until no diff).

9. **Modules** — what they are, why they exist (DRY, consistency), the folder structure, how to call one, how outputs pass between module and caller.

10. **`count` vs `for_each`** — `count` uses numeric index (shifting on deletion), `for_each` uses string keys (stable). Know when to use each.

11. **Dynamic blocks** — generating repeated nested blocks from a variable. Security group ingress rules are the classic example.

12. **Never commit secrets** — access keys never go in `.tf` files. Use env vars, IAM roles, or AWS Secrets Manager. Add `*.tfvars` to `.gitignore` if it contains sensitive values.

13. **Terraform in CI/CD** — `plan` runs on PR (for review), `apply` runs on merge to main (automated deployment). Use OIDC for AWS auth in GitHub Actions — no stored access keys.

14. **Describe your ECS capstone infrastructure as code** — be able to say "I provisioned the VPC, subnets, ECS cluster, ALB, ACM certificate, and Route53 record all with Terraform. The state is stored in S3 with DynamoDB locking. The CI/CD pipeline runs `terraform plan` on PRs and `terraform apply` on merge." That answer covers the entire Concept AI and Optum JDs.
