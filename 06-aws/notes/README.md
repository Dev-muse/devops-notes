# ☁️ AWS for DevOps — Complete Beginner's Guide

> **Continued from:** Linux, Bash, Networking, Docker, and Git. You can use the command line confidently, understand networking fundamentals (IPs, DNS, subnets), and know how to containerise applications. AWS takes everything you know and runs it in the cloud — at any scale, in any region, with managed infrastructure.
>
> **How to use this document:** Work through it in order the first time. Plain-English explanation first, technical detail second, real commands third. Come back to any section whenever you forget something.
>
> **The goal:** Understand what AWS is and why it dominates the cloud market, navigate the global infrastructure model, set up IAM securely, launch and connect to EC2 instances, understand networking (VPC, security groups, load balancers), use storage (EBS, EFS), deploy containers on ECS and EKS, understand DNS with Route 53, and be ready for the ECS capstone project.

---

# Chapter 1 — Introduction to AWS

## 1.1 What is AWS?

**AWS (Amazon Web Services)** is the world's leading cloud computing platform. Instead of buying, racking, and managing physical servers yourself, you rent computing power, storage, databases, networking, and hundreds of other services from Amazon — paying only for what you use, by the second or hour.

AWS was built internally by Amazon starting in 2002 to solve their own infrastructure scaling problems. The insight was that the tools they built for themselves were so useful that other companies would pay to use them. They launched publicly in 2004 with SQS (Simple Queue Service) and expanded in 2006 with S3 (storage) and EC2 (virtual machines) — two services that are still the backbone of most cloud architectures today.

**By the numbers:**
- Around **47% global cloud market share** — the clear market leader
- Over **$35 billion in annual revenue**
- **200+ services** covering compute, storage, databases, AI/ML, networking, security, and more
- Used by Netflix, Airbnb, NASA, the NHS, and millions of other organisations

## 1.2 AWS use cases

| Use case | What AWS provides |
|---|---|
| Hosting web applications | EC2, ECS, Elastic Beanstalk, Lambda |
| Storing files and data | S3, EBS, EFS, Glacier |
| Running databases | RDS, DynamoDB, ElastiCache, Aurora |
| Delivering content globally | CloudFront CDN |
| DNS and domain management | Route 53 |
| CI/CD pipelines | CodePipeline, CodeBuild, CodeDeploy |
| Machine learning | SageMaker, Rekognition, Comprehend |
| Container orchestration | ECS, EKS, Fargate |

## 1.3 The main service categories

```
Compute:     EC2, Lambda, ECS, EKS, Fargate
Storage:     S3, EBS, EFS, Glacier
Databases:   RDS, DynamoDB, ElastiCache, Redshift
Networking:  VPC, Route 53, CloudFront, API Gateway, ELB
Security:    IAM, KMS, Secrets Manager, WAF, Shield
Monitoring:  CloudWatch, CloudTrail, Config
IaC:         CloudFormation, CDK
```

## 1.4 Global vs regional services

This is a distinction that trips up beginners. Most AWS services are **regional** — they exist in a specific geographic region and you choose which region you deploy to. A few services are **global** — they exist everywhere automatically.

| Global services | Regional services |
|---|---|
| IAM (users, roles, policies) | EC2 (instances) |
| Route 53 (DNS) | S3 (buckets — technically global namespace but region-specific) |
| CloudFront (CDN) | VPC, subnets, security groups |
| AWS Organisations | RDS, ECS, EKS |
| Billing and Cost Explorer | Lambda functions |

When you log into the AWS console, always check which region you're in (top-right corner). Resources in one region are not visible from another region.

---

# Chapter 2 — AWS Global Infrastructure

## 2.1 Regions

An **AWS Region** is a geographic area that contains multiple, isolated data centres. Each region is completely independent — it has its own power, networking, and facilities.

Examples of regions:
- `eu-west-1` — Ireland (closest to London, often used for EU workloads)
- `eu-west-2` — London
- `us-east-1` — Northern Virginia (the oldest and most feature-complete region)
- `ap-southeast-1` — Singapore
- `ap-northeast-1` — Tokyo

**How to choose a region:**
1. **Latency** — deploy close to your users. UK users → `eu-west-2` (London) or `eu-west-1` (Ireland).
2. **Data residency** — some regulations (GDPR, NHS data rules) require data to stay in specific geographies.
3. **Service availability** — not all services are available in all regions. New services launch in `us-east-1` first.
4. **Pricing** — prices vary by region. `us-east-1` tends to be cheapest.

## 2.2 Availability Zones (AZs)

Within each region, AWS has multiple **Availability Zones** — usually 3 to 6 per region.

An AZ is one or more discrete data centres with redundant power, networking, and connectivity. They are physically separated from each other (different buildings, different power grids, different flood plains) but connected via high-speed, low-latency private fibre links.

```
eu-west-1 Region (Ireland)
├── eu-west-1a  (data centre cluster A)
├── eu-west-1b  (data centre cluster B)
└── eu-west-1c  (data centre cluster C)
```

**Why AZs matter for DevOps:**

If you run your app in only one AZ and that data centre has a power failure or network issue, your app is down. If you spread across multiple AZs, one going down doesn't affect the others.

This is called **high availability** — designing your system so that a single component failure doesn't cause total downtime. Load balancers, Auto Scaling Groups, and managed services like RDS automatically spread across AZs.

> **Rule of thumb:** Always deploy production workloads across at least 2 AZs. 3 is ideal.

## 2.3 Points of Presence (Edge Locations)

AWS has **400+ Points of Presence** across 90+ cities worldwide — far more than the number of regions. These are not full data centres; they're edge nodes used by **CloudFront** (AWS's CDN).

When a user in Tokyo requests a static asset from your app hosted in London, CloudFront serves it from the nearest edge location in Tokyo — milliseconds instead of seconds.

```
User in Tokyo
     ↓
CloudFront Edge Location (Tokyo) ← cached copy of your asset
     (only on first request does it go back to your origin server in London)
```

---

# Chapter 3 — Account Setup, Console and Billing

## 3.1 Creating your AWS account

1. Go to [aws.amazon.com](https://aws.amazon.com) and click "Create an AWS Account"
2. Enter your email address — this becomes the **root account email**
3. Set a strong root password (this is the most powerful account in your AWS setup)
4. Enter billing details — AWS requires a credit/debit card even for the free tier
5. Verify identity via SMS or voice call
6. Select the **Basic Support plan** (free) — you don't need paid support to start

**The AWS Free Tier** gives you:
- 750 hours/month of `t2.micro` or `t3.micro` EC2 (enough for one instance running 24/7)
- 5 GB of S3 storage
- 750 hours of RDS (micro instance)
- 1 million Lambda invocations/month
- Much more — check [aws.amazon.com/free](https://aws.amazon.com/free) for the full list

## 3.2 Navigating the AWS Console

The console is at [console.aws.amazon.com](https://console.aws.amazon.com).

Key UI elements to know:
- **Region selector** (top-right) — always check this first. If you can't see your resources, you're probably in the wrong region.
- **Account ID** (top-right, under your account name) — a 12-digit number that uniquely identifies your AWS account. You'll share this when setting up IAM cross-account access or ECR permissions.
- **Search bar** (top-centre) — the fastest way to navigate. Type "EC2", "S3", "IAM" — faster than menus.
- **Services menu** — grouped by category: Compute, Storage, Database, etc.
- **CloudShell** (top-right) — a browser-based terminal with the AWS CLI pre-installed and authenticated. Useful for quick commands without local setup.

## 3.3 Billing setup — do this immediately

Billing surprises are the most common painful experience for AWS beginners. Set up alerts before you do anything else.

```
AWS Console → Billing and Cost Management → Budgets → Create Budget
```

```
1. Choose "Use a template" → "Zero spend budget"
   (alerts you the moment you spend anything outside the free tier)

2. Also create a monthly cost budget:
   → Budget amount: $10 (or whatever your limit is)
   → Alert: email at 80% of budget
```

You can also view your current estimated charges:
```
Billing → Bills → Current month
Billing → Free Tier → Shows how close you are to free tier limits
```

> **Clean up after every lab.** Terminate EC2 instances, delete load balancers, release Elastic IPs, and delete NAT Gateways when you're done. These are the main sources of unexpected charges. Set a calendar reminder to audit your resources weekly.

## 3.4 MFA — set this up before anything else

**MFA (Multi-Factor Authentication)** requires a second proof of identity beyond your password. Even if your password is stolen, an attacker can't access your account without the second factor.

On AWS, there are three MFA options:

| Type | Examples | Best for |
|---|---|---|
| **Virtual authenticator app** | Google Authenticator, Authy, 1Password | Most people — free and convenient |
| **Hardware security key** | YubiKey, AWS-supported FIDO2 keys | High-security environments |
| **SMS / voice** | Text message to your phone | Weakest option — SIM-swap attacks are a risk |

**Set up MFA on the root account:**
```
Console → Your account name (top-right) → Security credentials
→ Multi-factor authentication → Assign MFA device
→ Choose "Authenticator app" → Scan QR code with your app
→ Enter two consecutive codes to verify
```

> **Root account rules:**
> - Enable MFA on it immediately.
> - Do not use it for day-to-day work.
> - Do not create access keys for it.
> - Create an IAM admin user and use that instead.
> - Lock the root credentials away and only use it for billing or account recovery.

---

# Chapter 4 — IAM: Identity and Access Management

## 4.1 What is IAM?

**IAM (Identity and Access Management)** is the system that controls **who** can access **what** in your AWS account, and **what they can do** with it.

Every action in AWS — whether through the console, CLI, or SDK — goes through IAM. Every API call is authenticated (who are you?) and authorised (are you allowed to do this?).

IAM is a **global service** — IAM users, groups, roles, and policies apply across all regions in your account.

> **Analogy:** IAM is the security system of your office building. Some people have keycard access to every floor (admins). Some can only enter specific rooms (developers with access to only their service). Contractors get temporary badges (roles). The policy document on the wall says who can go where and do what.

## 4.2 Users

An **IAM user** represents one person or one application that needs to access AWS.

Each user has:
- A **username** (e.g. `alice`, `deploy-bot`)
- **Credentials** — either a password (for console access) or access keys (for CLI/SDK access), or both
- **Permissions** — defined by policies attached directly or via groups

```bash
# Create a user via CLI
aws iam create-user --user-name alice

# List all users
aws iam list-users
```

**Best practice:** One IAM user per person. Do not share users. Do not use the root account as a user.

## 4.3 Groups

An **IAM group** is a collection of users. You attach policies to the group, and all users in the group inherit those permissions.

```
Group: Developers
  Policy: EC2FullAccess, S3ReadOnly
  Members: alice, bob, carol

Group: Admins
  Policy: AdministratorAccess
  Members: dave
```

If you add alice to the Developers group, she immediately gets EC2 and S3 access. Remove her from the group and the permissions are gone. Groups make permission management at scale sane.

```bash
# Create a group
aws iam create-group --group-name Developers

# Add a user to a group
aws iam add-user-to-group --group-name Developers --user-name alice

# Attach a policy to a group
aws iam attach-group-policy \
  --group-name Developers \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
```

Note: users can belong to multiple groups. A user's effective permissions are the union of all permissions from all groups they belong to, plus any directly attached policies.

## 4.4 Policies

A **policy** is a JSON document that defines what actions are allowed or denied on which resources.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": "ec2:TerminateInstances",
      "Resource": "*"
    }
  ]
}
```

Breaking this down:
- `Effect`: `Allow` or `Deny`
- `Action`: the API call being controlled. `"ec2:*"` means all EC2 actions. `"s3:GetObject"` means just reading S3 objects.
- `Resource`: which specific resources. `"*"` means all. You can specify a single resource ARN like `"arn:aws:s3:::my-bucket/*"`

**Types of policies:**

| Type | What it is | When to use |
|---|---|---|
| **AWS managed** | Pre-built by AWS, maintained by AWS | Starting point — `AdministratorAccess`, `ReadOnlyAccess`, `AmazonEC2FullAccess` |
| **Customer managed** | You create and maintain it | When AWS managed policies are too broad or too narrow |
| **Inline** | Embedded directly in a user/group/role | Avoid — hard to manage, can't reuse |

## 4.5 Policy inheritance

Policies attach to users, groups, or roles. A user's effective permissions come from all policies applied to them from all sources:

```
alice's effective permissions =
  Policies attached directly to alice
  + Policies from Group A (Developers)
  + Policies from Group B (QA-Team)
```

**Deny always wins.** If any policy explicitly denies an action, the deny overrides any allows. If no policy allows an action, it is implicitly denied. This is the default-deny model.

## 4.6 The least privilege principle

> **Give users and services only the permissions they need to do their specific job — nothing more.**

In practice:
- A developer deploying to EC2 should have EC2 access — not RDS, not IAM, not billing.
- A CI/CD pipeline pushing to ECR should have ECR push permissions — not EC2 start/stop.
- A Lambda function reading from S3 should have S3 read on that specific bucket — not all of S3.

Start with the minimum and add permissions when they're actually needed. This limits the blast radius if credentials are compromised.

## 4.7 Password policy

```
IAM Console → Account settings → Password policy
```

Set a strong policy:
- Minimum length: 12+ characters
- Require uppercase, lowercase, numbers, symbols
- Prevent password reuse (last 3–5 passwords)
- Require password rotation (90 days for high-security environments)

## 4.8 Roles

An **IAM role** is like a user, but it has no permanent credentials. Instead, it can be **assumed** by:
- An AWS service (e.g. an EC2 instance needs to call S3)
- A user from another AWS account
- A web identity (Google, Facebook — for mobile apps)
- A CI/CD system like GitHub Actions

When something assumes a role, it gets **temporary credentials** (valid for 15 minutes to 12 hours) that automatically expire.

```
EC2 instance needs to read from S3
  ↓
Attach an IAM Role with S3ReadOnly policy to the EC2 instance
  ↓
Code running on the EC2 instance automatically gets temporary credentials
  ↓
No access keys needed in code or environment variables
```

This is the right way to give AWS services access to other AWS services. Never put access keys inside an EC2 instance when a role can do the job.

**Common role use cases in DevOps:**

| Who assumes the role | Why |
|---|---|
| EC2 instance | To read from S3, write to CloudWatch, push to ECR |
| ECS task | To access DynamoDB, read from Secrets Manager |
| Lambda function | To write to S3, publish to SNS |
| GitHub Actions (OIDC) | To deploy to ECS, push to ECR — without storing access keys in secrets |

## 4.9 IAM Security Tools

```bash
# IAM Credential Report — download a CSV showing all users and the status
# of their credentials (passwords, access keys, MFA)
aws iam generate-credential-report
aws iam get-credential-report

# IAM Access Advisor — shows which services a user/role has permission to
# access and when they last accessed them. Use this to find and remove
# unused permissions.
# (Available in the IAM Console → Users → Access Advisor tab)
```

Use the credential report to audit your account periodically:
- Who has access keys they haven't used in 90 days? Delete them.
- Who doesn't have MFA enabled? Enforce it.
- Who is using the root account? Stop that.

## 4.10 Accessing AWS — three methods

| Method | How | When to use |
|---|---|---|
| **Management Console** | Browser at console.aws.amazon.com | Learning, one-off tasks, visual inspection |
| **AWS CLI** | `aws` command in your terminal | Scripts, automation, daily DevOps work |
| **AWS SDK** | Code libraries (Python boto3, JS, Go...) | Applications that need to talk to AWS |

## 4.11 Access keys and the CLI

**Access keys** are credentials used for programmatic access (CLI and SDK). They consist of:
- **Access Key ID** — like a username (e.g. `AKIAIOSFODNN7EXAMPLE`)
- **Secret Access Key** — like a password (shown only once on creation)

```bash
# Install the AWS CLI
# macOS:
brew install awscli
# Ubuntu:
sudo apt install awscli
# Or via pip:
pip install awscli

# Configure with your access key
aws configure
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtn...
# Default region name: eu-west-2
# Default output format: json

# Verify it worked
aws sts get-caller-identity
# Returns your account ID, user ID, and ARN — confirms you're authenticated
```

Access keys are stored in `~/.aws/credentials` and `~/.aws/config`.

**Critical security rules for access keys:**

- **Never commit access keys to Git.** Not even private repos. GitHub scans for them and notifies AWS. Attackers scrape public repos continuously.
- Rotate keys regularly — create a new one, update your systems, then delete the old one.
- Delete unused keys. The credential report shows you which ones haven't been used.
- Use IAM roles instead of access keys whenever possible (on EC2, ECS, Lambda).
- For CI/CD, use OIDC (GitHub Actions can assume an IAM role directly — no stored keys).

```bash
# Check who the current CLI session is authenticated as
aws sts get-caller-identity

# List your configured profiles
aws configure list-profiles

# Use a named profile
aws --profile production s3 ls

# See what access key is configured
aws configure list
```

## 4.12 IAM best practices — summary

```
✅ Enable MFA on the root account immediately
✅ Never use the root account for daily work
✅ Create an IAM admin user for admin tasks
✅ Create individual IAM users — never share credentials
✅ Use groups to assign permissions, not individual users
✅ Follow the least privilege principle — start minimal, add as needed
✅ Use roles for AWS services — never access keys inside EC2 or Lambda
✅ Rotate access keys regularly
✅ Never commit access keys to code repositories
✅ Use the IAM credential report to audit periodically
✅ Enable IAM Access Advisor to find and remove unused permissions
```

---

# Chapter 5 — EC2: Virtual Machines in the Cloud

## 5.1 What is EC2?

**Amazon EC2 (Elastic Compute Cloud)** is AWS's virtual machine service. An EC2 instance is a virtual server running in AWS — just like running Ubuntu on VirtualBox, except it's in Amazon's data centre, accessible over the internet, and you pay by the hour (or second).

EC2 is the most important service to understand first because almost every other AWS service either runs on EC2 underneath, connects to EC2, or is compared to EC2 as an alternative.

## 5.2 What you configure when launching an instance

When you launch an EC2 instance, you choose:

| Setting | What it is | Example |
|---|---|---|
| **AMI** | The operating system image | Amazon Linux 2023, Ubuntu 22.04, Windows Server |
| **Instance type** | CPU and RAM | `t3.micro` (2 vCPU, 1GB RAM), `m5.large` (2 vCPU, 8GB RAM) |
| **Key pair** | SSH key for access | Your `.pem` file |
| **Network settings** | VPC, subnet, security group | Your VPC, public subnet, allow port 22 |
| **Storage** | EBS volume(s) | 20GB gp3 volume |
| **User data** | Script to run on first boot | Install nginx, configure the app |
| **IAM role** | What AWS services this instance can access | S3ReadOnly, ECRPush |

## 5.3 Instance types

Instance types follow a naming pattern: `family.size`

- **Family** indicates the hardware type
- **Size** indicates how much of it

| Family | Optimised for | Use case | Examples |
|---|---|---|---|
| **t** | Burstable | Dev/test, low-traffic apps | `t3.micro`, `t3.medium` |
| **m** | General purpose | Most web apps and APIs | `m5.large`, `m6i.xlarge` |
| **c** | Compute (CPU) | High CPU workloads, batch | `c5.2xlarge`, `c6g.large` |
| **r** | Memory (RAM) | Databases, in-memory caches | `r5.2xlarge`, `r6g.large` |
| **i** | Storage I/O | High-performance databases | `i3.large` |
| **g** / **p** | GPU | ML training, rendering | `g4dn.xlarge`, `p3.2xlarge` |

Size progression: `nano` → `micro` → `small` → `medium` → `large` → `xlarge` → `2xlarge` → `4xlarge` → ...

**The free tier:** `t2.micro` or `t3.micro` — 1 vCPU, 1GB RAM. Good enough for learning, a development server, or a lightweight web app.

## 5.4 Purchasing options

| Option | What it means | Savings | Best for |
|---|---|---|---|
| **On-Demand** | Pay per second, no commitment | — (baseline) | Dev/test, unpredictable workloads |
| **Reserved** | 1 or 3 year commitment | Up to 72% | Production apps with steady load |
| **Savings Plans** | Flexible commitment to usage amount | Up to 66% | Flexible alternative to Reserved |
| **Spot** | Bid on spare capacity — AWS can reclaim with 2 min notice | Up to 90% | Batch jobs, fault-tolerant workloads |
| **Dedicated Hosts** | Physical server dedicated to you | — | Compliance, licensing requirements |

**DevOps guidance:**
- Use **On-Demand** for development and testing
- Use **Reserved** or **Savings Plans** for production instances that run continuously
- Use **Spot** for batch processing jobs, CI/CD build runners, and any workload that can handle interruption

## 5.5 AMIs — Amazon Machine Images

An **AMI** is a template that defines the OS, pre-installed software, and configuration of an instance. When you launch an EC2 instance, you choose an AMI.

Types of AMIs:
- **AWS-provided** — Amazon Linux 2023, Ubuntu, Windows Server (keep these updated for security patches)
- **AWS Marketplace** — pre-configured by vendors (e.g. Bitnami, Palo Alto)
- **Your own** — you can create an AMI from a running instance to duplicate it exactly

AMIs are region-specific — an AMI in `eu-west-1` must be copied before using it in `us-east-1`.

## 5.6 User Data — the bootstrap script

**EC2 User Data** is a script that runs automatically when an instance first boots. It's how you automate the initial configuration.

```bash
#!/bin/bash
# This runs as root on first boot

# Update the system
yum update -y

# Install nginx
yum install -y nginx

# Start and enable it
systemctl start nginx
systemctl enable nginx

# Write a simple page
echo "<h1>Hello from EC2!</h1>" > /var/www/html/index.html
```

In the console: **Launch Instance → Advanced Details → User data** — paste your script here.

This is the simplest form of infrastructure automation. Terraform and Ansible take this much further, but understanding User Data is important because it's what happens at the base level.

## 5.7 Connecting to your EC2 instance via SSH

```bash
# 1. When launching, create a new key pair and download the .pem file
# 2. Fix the permissions on the key file (SSH refuses to use it otherwise)
chmod 400 my-key.pem

# 3. Get the public IP of your instance from the EC2 console

# 4. Connect
ssh -i my-key.pem ec2-user@YOUR_PUBLIC_IP
# For Ubuntu AMIs, the user is 'ubuntu'
ssh -i my-key.pem ubuntu@YOUR_PUBLIC_IP

# Once connected, you're on the server:
whoami        # ec2-user or ubuntu
hostname      # the instance's internal hostname
df -h         # check disk space
free -h       # check memory
```

---

# Chapter 6 — Security Groups

## 6.1 What are security groups?

A **security group** is a virtual firewall that controls inbound and outbound traffic to an EC2 instance (or other resources like RDS, ELB).

Security groups are **stateful** — if you allow inbound traffic on port 80, the return traffic is automatically allowed. You don't need a separate outbound rule for the response.

Every EC2 instance must have at least one security group. By default:
- All inbound traffic is **blocked**
- All outbound traffic is **allowed**

## 6.2 Security group rules

Each rule specifies:
- **Type/Protocol** — TCP, UDP, ICMP
- **Port range** — 22 (SSH), 80 (HTTP), 443 (HTTPS), 3306 (MySQL), etc.
- **Source/Destination** — an IP range (CIDR), another security group, or "anywhere" (`0.0.0.0/0`)

```
Inbound rules for a web server:
  Type: SSH,    Port: 22,   Source: My IP only (e.g. 82.33.44.55/32)
  Type: HTTP,   Port: 80,   Source: Anywhere (0.0.0.0/0)
  Type: HTTPS,  Port: 443,  Source: Anywhere (0.0.0.0/0)

Outbound rules (usually leave as default):
  All traffic → Anywhere (0.0.0.0/0)
```

## 6.3 Classic ports to memorise

| Port | Protocol | Service |
|---|---|---|
| 22 | TCP | SSH — remote server access |
| 80 | TCP | HTTP — web traffic |
| 443 | TCP | HTTPS — encrypted web traffic |
| 3306 | TCP | MySQL / Aurora |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis |
| 27017 | TCP | MongoDB |
| 3389 | TCP | RDP — Windows remote desktop |
| 8080 | TCP | HTTP alternative (dev servers, proxies) |

## 6.4 Referencing security groups as sources

A powerful pattern: instead of specifying an IP range as the source, specify another security group. This means "allow traffic from any instance that has this security group attached."

```
Web server security group:
  Inbound: Port 80 from anywhere
  Outbound: Port 3306 to DB security group

Database security group:
  Inbound: Port 3306 from Web server security group only
  (Not from anywhere — the DB is not directly accessible from the internet)
```

This is more secure and more flexible than IP-based rules. When you scale from 1 web server to 10, all 10 automatically get access to the database — no rule updates needed.

## 6.5 Security groups vs NACLs

| | Security Group | NACL |
|---|---|---|
| Level | Instance level | Subnet level |
| Stateful | Yes — return traffic auto-allowed | No — you need rules in both directions |
| Rules | Allow only | Allow and Deny |
| Evaluation | All rules evaluated | Rules evaluated in number order, first match wins |
| Default | Deny all inbound | Allow all traffic |

Security groups are what you'll use most of the time. NACLs add an extra layer of defence at the subnet level — used for broad block/allow rules across an entire subnet.

---

# Chapter 7 — IP Addressing on AWS

## 7.1 Private vs public IPs

Every EC2 instance in a public subnet gets:
- A **private IP** — internal, only accessible within the VPC (e.g. `10.0.1.50`)
- A **public IP** — externally accessible, assigned dynamically (e.g. `54.72.140.23`)

The public IP changes every time you stop and start the instance. This is a problem if you have DNS pointing to it or other systems that depend on a fixed IP.

## 7.2 Elastic IPs

An **Elastic IP** is a static, public IPv4 address that you own and can assign to any instance. Unlike the auto-assigned public IP, it doesn't change when you stop and start the instance.

```bash
# Allocate an Elastic IP
aws ec2 allocate-address --domain vpc

# Associate it with an instance
aws ec2 associate-address \
  --instance-id i-1234567890abcdef0 \
  --allocation-id eipalloc-12345678

# Disassociate
aws ec2 disassociate-address --association-id eipassoc-12345678

# Release (important — you're charged for allocated but unassociated EIPs)
aws ec2 release-address --allocation-id eipalloc-12345678
```

> **When to use Elastic IPs:** When you need a fixed public IP for a single instance (legacy apps, specific firewall rules). In modern architectures, use a load balancer (which has its own fixed DNS name) rather than Elastic IPs. AWS charges for Elastic IPs that are allocated but not attached to a running instance — release them when not in use.

## 7.3 IPv4 vs IPv6

AWS supports both. IPv4 is still the default. IPv6 gives every resource a globally unique address (no need for NAT) and is increasingly required for certain workloads. In your VPC, you can enable IPv6 and assign IPv6 CIDR blocks to subnets.

---

# Chapter 8 — Storage

## 8.1 EBS — Elastic Block Store

An **EBS volume** is a network-attached block storage device — like a virtual hard drive that you attach to an EC2 instance. It persists independently of the instance — stop and start the instance, the data is still there. Delete the instance (without deleting the volume), the data is still there.

Key properties:
- **Specific to one AZ** — an EBS volume in `eu-west-2a` cannot be attached to an instance in `eu-west-2b`
- **Attached to one instance at a time** (by default — io1/io2 volumes support multi-attach)
- **Persists independently** — can be detached and re-attached to a different instance
- **Snapshots** — point-in-time backups stored in S3, can be used to create new volumes or AMIs

EBS volume types:

| Type | Use case | Notes |
|---|---|---|
| `gp3` | General purpose SSD | Default for most workloads — 3000 IOPS baseline, cheap |
| `gp2` | General purpose SSD (older) | Being phased out in favour of gp3 |
| `io1` / `io2` | Provisioned IOPS SSD | High-performance databases — expensive |
| `st1` | Throughput-optimised HDD | Big data, data warehouses |
| `sc1` | Cold HDD | Infrequent access, cheapest option |

```bash
# List EBS volumes
aws ec2 describe-volumes

# Create a snapshot of a volume
aws ec2 create-snapshot \
  --volume-id vol-12345678 \
  --description "Before OS upgrade"

# List snapshots
aws ec2 describe-snapshots --owner-ids self
```

## 8.2 AMI — Amazon Machine Image (deeper look)

An **AMI** (covered in Chapter 5) is built from an EBS snapshot — it captures the root volume of an instance. Creating your own AMI is how you:

- Clone an instance to another AZ or region
- Create identical instances at scale (all starting from the same base)
- Capture a known-good state before a risky change

```bash
# Create an AMI from a running instance
aws ec2 create-image \
  --instance-id i-1234567890abcdef0 \
  --name "my-app-v1.0" \
  --description "App server before v1.1 deployment"

# Copy an AMI to another region
aws ec2 copy-image \
  --source-image-id ami-12345678 \
  --source-region eu-west-1 \
  --region eu-west-2 \
  --name "my-app-v1.0-copy"
```

## 8.3 EFS — Elastic File System

**EFS** is a managed, shared network file system. Unlike EBS (one volume, one instance, one AZ), EFS:

- Can be mounted by **multiple EC2 instances simultaneously**
- Is **multi-AZ** — automatically replicates across AZs in the region
- Is **elastic** — grows and shrinks automatically as you add/remove files
- Uses the **NFS protocol** — mount it like any NFS share

| | EBS | EFS |
|---|---|---|
| Access | One instance at a time | Many instances simultaneously |
| AZ scope | Single AZ | Multi-AZ (regional) |
| Size | Fixed when created | Grows automatically |
| Use case | Root volumes, databases | Shared content, CMS files, home directories |
| Cost | Cheaper | More expensive per GB |

---

# Chapter 9 — Load Balancing and Auto Scaling

## 9.1 Scalability and high availability

**Scalability** means your system can handle more load. Two approaches:

- **Vertical scaling** — make the instance bigger (from `t3.small` to `m5.xlarge`). Simple but has a ceiling — you can only make one machine so big. Requires downtime to change instance type.
- **Horizontal scaling** — add more instances (from 1 to 10 `t3.small` instances). No ceiling. No single point of failure. Requires a load balancer to distribute traffic.

**High availability** means your system keeps working even when components fail. Achieved by running across multiple AZs with redundant instances.

Modern production architectures aim for both: horizontal scalability *and* high availability across AZs.

## 9.2 What is a load balancer?

A **load balancer** sits in front of your instances and distributes incoming traffic across them.

```
Internet
   ↓
Load Balancer (one public endpoint)
   ├──→ Instance 1 (eu-west-2a)
   ├──→ Instance 2 (eu-west-2b)
   └──→ Instance 3 (eu-west-2c)
```

Benefits:
- **Distributes load** — no single instance gets overwhelmed
- **Health checks** — automatically stops sending traffic to unhealthy instances
- **Single DNS name** — your users connect to one address that never changes
- **SSL termination** — the load balancer handles HTTPS, instances only need HTTP
- **Multi-AZ** — spans AZs so AZ failure doesn't take down the service

## 9.3 AWS load balancer types

AWS provides **ELB (Elastic Load Balancing)** with three types:

### Application Load Balancer (ALB) — Layer 7

The most commonly used type for modern web applications. Works at the HTTP/HTTPS level.

**Can route based on:**
- URL path: `/api/*` → backend service, `/` → frontend service
- Host header: `api.example.com` → backend, `www.example.com` → frontend
- HTTP headers, query strings, source IP

**Use for:** Web applications, microservices, containers on ECS

### Network Load Balancer (NLB) — Layer 4

Works at the TCP/UDP level. Extremely high performance and low latency. Handles millions of requests per second. Preserves the source IP.

**Use for:** Gaming, real-time apps, when you need a static IP on the load balancer, TCP workloads

### Classic Load Balancer (CLB) — Deprecated

The original ELB. Don't use it for new applications — use ALB or NLB.

## 9.4 Target groups

A **target group** is the collection of backends that a load balancer routes traffic to. Targets can be:
- EC2 instances
- IP addresses
- Lambda functions (ALB only)
- ECS tasks

You can have multiple target groups — the ALB uses listener rules to decide which target group gets which request.

## 9.5 Health checks

Load balancers continuously check whether their targets are healthy by making HTTP requests to a health check endpoint.

```
ALB health check:
  Protocol: HTTP
  Path: /health
  Port: 80
  Healthy threshold: 3 successful checks
  Unhealthy threshold: 2 failed checks
  Interval: 30 seconds
```

If an instance fails 2 consecutive health checks, the load balancer stops sending traffic to it. When it passes 3 consecutive checks, traffic resumes. Your app **must** have a `/health` endpoint that returns HTTP 200.

## 9.6 SSL/TLS on load balancers

The load balancer handles HTTPS so your instances don't have to:

1. Request a certificate from **ACM (AWS Certificate Manager)** — free for public certs
2. Attach the cert to the ALB listener on port 443
3. ALB decrypts HTTPS traffic and forwards plain HTTP to the instances
4. Instances only need to handle HTTP internally

**SNI (Server Name Indication)** allows one load balancer to serve multiple SSL certificates for multiple domains. The client sends the hostname it's connecting to in the TLS handshake; the ALB picks the right cert.

## 9.7 Sticky sessions

By default, the load balancer routes each request to any healthy instance. **Sticky sessions** (session affinity) bind a user's requests to the same instance for the duration of their session.

This is needed when an app stores session state locally on the instance (old-school apps). Modern apps should store state in a shared store (Redis, DynamoDB) and not need sticky sessions.

## 9.8 Connection draining

When you take an instance out of service (scaling down, deploying a new version), **connection draining** gives existing connections time to complete before the instance is removed. Set a timeout of 60–300 seconds. New requests go to other instances immediately; in-progress requests continue until complete or the timeout expires.

## 9.9 Auto Scaling Groups (ASG)

An **Auto Scaling Group** automatically launches or terminates EC2 instances based on demand.

```
Min capacity: 2   (always at least 2 instances)
Max capacity: 10  (never more than 10)
Desired capacity: 4  (target during normal load)

Scaling policy: if average CPU > 70% for 5 minutes → add 2 instances
Scaling policy: if average CPU < 30% for 10 minutes → remove 1 instance
```

ASG + ALB is the standard pattern for scalable web applications:

```
ALB (receives traffic)
  ↓
Target Group
  ↓
Auto Scaling Group (manages instances)
  ├── Instance 1 (eu-west-2a)
  ├── Instance 2 (eu-west-2b)
  └── Instance 3 (eu-west-2c) ← added automatically during traffic spike
```

**Scaling policies:**

| Policy type | How it works | When to use |
|---|---|---|
| **Target tracking** | Keep a metric at a target value (e.g. keep CPU at 60%) | Simplest — most common |
| **Step scaling** | Add/remove different amounts based on how far over/under you are | More precise control |
| **Scheduled scaling** | Scale at a specific time (e.g. add capacity every morning at 8am) | Predictable traffic patterns |
| **Predictive scaling** | ML-based — anticipates demand based on historical patterns | High traffic variability |

**CloudWatch alarms** trigger scaling actions. When CPU average exceeds 70% for 5 minutes, CloudWatch fires an alarm that tells the ASG to add instances.

---

# Chapter 10 — Containers on AWS

## 10.1 Container services overview

You already understand Docker and containers. AWS provides managed services to run them at scale without managing the underlying servers yourself.

| Service | What it is | Use case |
|---|---|---|
| **ECR** | Elastic Container Registry — private Docker registry | Store your Docker images |
| **ECS** | Elastic Container Service — AWS-native orchestration | Run containers on AWS, simpler than K8s |
| **EKS** | Elastic Kubernetes Service — managed Kubernetes | Run Kubernetes clusters on AWS |
| **Fargate** | Serverless compute engine for containers | Run containers without managing EC2 instances |
| **App Runner** | Fully managed container hosting | Simplest option — just provide your image |

## 10.2 Amazon ECR

**ECR** is AWS's private Docker registry. You push your images here and ECS/EKS pulls from it.

```bash
# Create a repository
aws ecr create-repository \
  --repository-name my-flask-app \
  --region eu-west-2

# Authenticate Docker to ECR
aws ecr get-login-password --region eu-west-2 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-2.amazonaws.com

# Build, tag, and push
docker build -t my-flask-app .
docker tag my-flask-app:latest \
  123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-flask-app:latest
docker push \
  123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-flask-app:latest

# List images in a repo
aws ecr list-images --repository-name my-flask-app

# Delete old images
aws ecr batch-delete-image \
  --repository-name my-flask-app \
  --image-ids imageTag=old-version
```

## 10.3 Amazon ECS — EC2 launch type

**ECS** manages how and where your containers run. In **EC2 launch type**, you provision and manage the EC2 instances yourself — ECS handles scheduling and running containers on them.

Key ECS concepts:

| Concept | What it is |
|---|---|
| **Task Definition** | The blueprint for your container — image, CPU, memory, ports, env vars, IAM role |
| **Task** | A running instance of a task definition |
| **Service** | Keeps a specified number of tasks running, integrates with ALB, handles rolling deploys |
| **Cluster** | A logical group of resources (EC2 instances or Fargate capacity) |

```bash
# Register a task definition
aws ecs register-task-definition \
  --family my-flask-app \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 256 \
  --memory 512 \
  --container-definitions '[
    {
      "name": "flask-app",
      "image": "123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-flask-app:latest",
      "portMappings": [{"containerPort": 5000, "protocol": "tcp"}],
      "essential": true
    }
  ]'

# Create a service
aws ecs create-service \
  --cluster my-cluster \
  --service-name flask-service \
  --task-definition my-flask-app:1 \
  --desired-count 2 \
  --launch-type FARGATE

# List running tasks
aws ecs list-tasks --cluster my-cluster

# See task details
aws ecs describe-tasks \
  --cluster my-cluster \
  --tasks TASK_ARN
```

## 10.4 IAM roles for ECS

ECS tasks need IAM roles to access other AWS services:

- **Task execution role** — used by ECS itself to pull the image from ECR and write logs to CloudWatch. Needs `AmazonECSTaskExecutionRolePolicy`.
- **Task role** — used by your application code to call other AWS services (S3, DynamoDB, Secrets Manager). This is what your Python/Node code uses when it calls `boto3`.

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ecs-tasks.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
```

## 10.5 ECS with a load balancer

In production, ECS services sit behind an ALB:

```
Internet → ALB (port 443) → Target Group → ECS Tasks (port 5000)
```

When ECS deploys a new version (rolling update), it:
1. Launches new tasks
2. Waits for them to pass health checks
3. Registers them with the target group
4. Deregisters old tasks
5. Terminates old tasks

Zero downtime deployments, automated.

## 10.6 ECS Service Auto Scaling

```bash
# ECS services can scale based on CloudWatch metrics:
# - CPU utilisation
# - Memory utilisation  
# - ALB request count per target

aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/my-cluster/flask-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10
```

## 10.7 Amazon EKS — managed Kubernetes

**EKS** is AWS's managed Kubernetes service. AWS manages the control plane (the Kubernetes API server, etcd, scheduler); you manage the worker nodes (or use Fargate to manage those too).

EKS gives you the full Kubernetes API — `kubectl` works exactly as on any other Kubernetes cluster. AWS handles upgrades, availability, and scaling of the control plane.

**EKS node types:**

| Type | What it means |
|---|---|
| **Managed node groups** | AWS provisions and manages EC2 instances for you |
| **Self-managed nodes** | You provision EC2 instances and join them to the cluster |
| **Fargate** | Serverless — no node management at all |

**EKS vs ECS:**

| | ECS | EKS |
|---|---|---|
| Orchestration | AWS-proprietary | Kubernetes (open standard) |
| Complexity | Simpler | More complex |
| Portability | AWS-only | Any Kubernetes cluster (cloud or on-prem) |
| Ecosystem | AWS tools | Massive Kubernetes ecosystem (Helm, Kustomize, ArgoCD) |
| Learning curve | Gentler | Steeper |
| Use when | Staying AWS-native | Need Kubernetes features, multi-cloud, or existing K8s experience |

## 10.8 AWS Fargate — serverless containers

**Fargate** is a serverless compute engine for containers. You define the task (image, CPU, memory) and Fargate runs it — no EC2 instances to manage, patch, or resize.

```
ECS on EC2:     You manage the EC2 instances. ECS schedules containers on them.
ECS on Fargate: You define the container. AWS manages everything underneath.
```

Fargate costs slightly more per compute unit than EC2, but you save the operational overhead of managing instances (patching, capacity planning, node rotation). For most teams, the operational savings are worth the price premium.

---

# Chapter 11 — Serverless: Lambda

## 11.1 What is serverless?

**Serverless** doesn't mean no servers — it means you don't manage them. AWS provisions, scales, and maintains the infrastructure. You only provide the code.

You pay only for execution time — if your function runs for 200ms, you pay for 200ms. If it's not running, you pay nothing.

## 11.2 AWS Lambda

**Lambda** runs your code in response to events. You write a function; Lambda runs it when triggered.

Supported runtimes: Python, Node.js, Java, Go, Ruby, .NET, and custom runtimes.

**Common event sources:**
- API Gateway — HTTP request arrives → Lambda runs
- S3 — a file is uploaded → Lambda processes it
- SQS — a message arrives in a queue → Lambda processes it
- DynamoDB Streams — a record changes → Lambda reacts
- CloudWatch Events — a scheduled time arrives → Lambda runs (like cron)
- SNS — a notification is published → Lambda handles it

**Example Lambda function (Python):**

```python
import json
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Triggered when a file is uploaded to S3
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    print(f"Processing file: {key} from bucket: {bucket}")

    # Do something with the file...

    return {
        'statusCode': 200,
        'body': json.dumps(f'Processed {key}')
    }
```

**Lambda limits:**
- Max execution time: 15 minutes
- Max memory: 10,240 MB (10 GB)
- Max package size: 250 MB unzipped
- Not suitable for: long-running processes, stateful workloads

**Lambda use cases in DevOps:**
- Automatically resize images uploaded to S3
- Trigger a Slack notification when a CloudWatch alarm fires
- Rotate secrets in Secrets Manager
- Process CloudTrail logs for security alerts
- Run scheduled maintenance tasks

---

# Chapter 12 — AWS Networking: VPC

## 12.1 What is a VPC?

**VPC (Virtual Private Cloud)** is your own private, isolated network within AWS. It's a logically isolated section of the AWS cloud where you launch resources.

Every AWS account gets a **default VPC** in each region — pre-configured with subnets in each AZ, an internet gateway, and routing that makes everything publicly accessible. This is fine for getting started but not for production.

For production, you create a **custom VPC** with a network design that separates public-facing resources from private ones.

## 12.2 CIDR notation review

You already know CIDR from the networking module. Here's how it applies to VPCs:

When you create a VPC, you choose a CIDR block that defines the IP address range:
- `10.0.0.0/16` — gives you 65,536 IP addresses (10.0.0.0 to 10.0.255.255)
- `10.0.0.0/24` — gives you 256 IP addresses (10.0.0.0 to 10.0.0.255)

Common VPC CIDR choices: `10.0.0.0/16`, `172.31.0.0/16`, `192.168.0.0/16` — all private ranges.

## 12.3 Subnets

A **subnet** is a range of IP addresses within your VPC. You create subnets in specific AZs.

**Public subnet** — has a route to an internet gateway. Resources here can have public IPs and communicate with the internet.

**Private subnet** — no direct route to the internet. Resources here are only accessible within the VPC (or via a bastion host / VPN / NAT gateway).

**Standard production VPC design (multi-AZ):**

```
VPC: 10.0.0.0/16

AZ eu-west-2a:
  Public subnet:  10.0.1.0/24  (web servers, load balancers)
  Private subnet: 10.0.2.0/24  (app servers, databases)

AZ eu-west-2b:
  Public subnet:  10.0.3.0/24
  Private subnet: 10.0.4.0/24

AZ eu-west-2c:
  Public subnet:  10.0.5.0/24
  Private subnet: 10.0.6.0/24
```

AWS reserves 5 IP addresses in each subnet (first 4 and last 1), so a `/24` subnet gives you 251 usable IPs.

## 12.4 Internet Gateway (IGW)

An **Internet Gateway** connects your VPC to the internet. Attach one to your VPC, add a route in the public subnet's route table pointing `0.0.0.0/0` to the IGW, and resources in that subnet can communicate with the internet (if they have a public IP).

```
Public subnet route table:
  10.0.0.0/16 → local    (traffic within VPC stays local)
  0.0.0.0/0   → igw-xxx  (everything else goes to internet)
```

## 12.5 NAT Gateway

Resources in **private subnets** need to reach the internet for things like downloading OS updates or calling external APIs — but you don't want them directly accessible from the internet.

A **NAT Gateway** lives in a public subnet and provides outbound internet access for private subnet resources:

```
Private subnet resource (10.0.2.50)
  → NAT Gateway (in public subnet, has an Elastic IP)
  → Internet Gateway
  → Internet
```

The private resource can initiate outbound connections. Inbound connections from the internet cannot reach it.

```
Private subnet route table:
  10.0.0.0/16 → local         (VPC-internal traffic)
  0.0.0.0/0   → nat-gateway-xxx  (outbound internet via NAT)
```

NAT Gateways are **charged per hour and per GB of data processed** — don't leave them running when not needed (destroy and recreate as needed in dev/test).

**High availability:** NAT Gateways are per-AZ. For multi-AZ high availability, create one NAT Gateway per AZ and configure each private subnet to use the NAT Gateway in its own AZ.

## 12.6 Bastion Host

A **bastion host** (also called a jump box) is a special EC2 instance in a public subnet that you use as an SSH gateway to reach instances in private subnets.

```
Your laptop
  → SSH to bastion host (public subnet, port 22 open to your IP)
  → SSH from bastion to private instance (port 22 open to bastion security group)
```

```bash
# SSH via bastion using agent forwarding
ssh -A -i my-key.pem ec2-user@BASTION_PUBLIC_IP

# From bastion, SSH to private instance
ssh ec2-user@PRIVATE_INSTANCE_IP
```

In modern architectures, **AWS Systems Manager Session Manager** replaces bastion hosts — you can shell into private instances through SSM without SSH or a bastion, and it's more secure (no inbound port 22 required).

## 12.7 NACLs — Network Access Control Lists

**NACLs** are an optional layer of security at the subnet level. They're stateless firewalls:
- Rules are evaluated in numbered order (lowest first)
- First matching rule wins
- Both inbound and outbound rules needed (stateless)
- Can explicitly deny traffic (security groups can only allow)

```
NACL for public subnet:
  Rule 100 Inbound:  Allow TCP 80 from 0.0.0.0/0
  Rule 110 Inbound:  Allow TCP 443 from 0.0.0.0/0
  Rule 120 Inbound:  Allow TCP 22 from MY_IP/32
  Rule 200 Inbound:  Allow TCP 1024-65535 from 0.0.0.0/0  (return traffic)
  Rule *   Inbound:  Deny all

  Rule 100 Outbound: Allow all TCP to 0.0.0.0/0
  Rule *   Outbound: Deny all
```

**Guidance:** Use security groups as your primary network security mechanism. Add NACLs for explicit denies or broad subnet-level rules.

## 12.8 VPC Peering

**VPC Peering** connects two VPCs so resources in each can communicate as if on the same network. Traffic stays on the AWS backbone — it doesn't go over the internet.

Use cases:
- Connect a production VPC to a logging/monitoring VPC
- Share services between different accounts or regions

Limitations:
- Non-transitive — if A peers with B, and B peers with C, A cannot reach C through B
- CIDR ranges must not overlap
- Route tables in both VPCs must be updated

## 12.9 VPC Endpoints

By default, traffic from a VPC to AWS services (S3, DynamoDB, etc.) goes over the internet. **VPC Endpoints** allow private connectivity to AWS services without internet traffic.

| Type | What it is | Use for |
|---|---|---|
| **Gateway endpoint** | Route table entry pointing to the service | S3, DynamoDB |
| **Interface endpoint** (PrivateLink) | Elastic network interface with private IP | Most other AWS services |

VPC endpoints improve security (no internet exposure) and reduce data transfer costs.

## 12.10 VPC Summary

```
VPC
├── Internet Gateway (for public subnets)
├── Subnets
│   ├── Public subnets (web servers, load balancers, NAT gateways, bastions)
│   │   └── Route table: 0.0.0.0/0 → IGW
│   └── Private subnets (app servers, databases)
│       └── Route table: 0.0.0.0/0 → NAT Gateway
├── Security Groups (instance-level, stateful firewall)
├── NACLs (subnet-level, stateless firewall)
├── NAT Gateway (outbound internet for private subnets)
└── VPC Endpoints (private access to AWS services)
```

---

# Chapter 13 — DNS with Route 53

## 13.1 What is Route 53?

**Route 53** is AWS's managed DNS service. It handles:
- **Domain registration** — buy and manage domain names
- **DNS hosting** — serve DNS records for your domains
- **Health checking** — monitor endpoints and route traffic away from unhealthy ones
- **Traffic routing** — intelligent routing policies

Route 53 is a **global service** — it doesn't live in a specific region.

The name comes from port 53, the port DNS uses.

## 13.2 Hosted zones

A **hosted zone** is a container for DNS records for a single domain (e.g. `example.com`).

- **Public hosted zone** — serves DNS records to the internet. Anyone can look up `www.example.com`.
- **Private hosted zone** — serves DNS records only within specified VPCs. Internal service discovery (`api.internal.example.com`).

```bash
# Create a public hosted zone
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference 2024-01-15-001

# List hosted zones
aws route53 list-hosted-zones
```

## 13.3 DNS record types in Route 53

You know these from the networking module. Here's how they apply in AWS:

| Record | Route 53 use |
|---|---|
| **A** | Point `www.example.com` to an EC2 IP or ALB IP |
| **CNAME** | Alias one name to another |
| **MX** | Email routing |
| **TXT** | Domain verification (ACM, Google Search Console) |
| **NS** | Name servers — automatically created with hosted zone |
| **SOA** | Start of authority — automatically created |

## 13.4 Alias records — the AWS-specific type

AWS adds an **Alias record** type that has no equivalent in standard DNS:

- Points to AWS resources (ALB, CloudFront, S3 website, API Gateway) by their DNS name
- Updates automatically when the resource's IP changes (important for load balancers)
- No TTL — always returns the current IP
- Free — no charge for DNS queries to alias records pointing at AWS resources

```
Standard A record: www.example.com → 54.72.140.23 (IP that can change)
Alias record:      www.example.com → my-alb.eu-west-2.elb.amazonaws.com (stable DNS name)
```

Use alias records when pointing to ALBs, CloudFront distributions, and other AWS resources.

## 13.5 Routing policies

Route 53 offers several routing policies:

| Policy | What it does | Use case |
|---|---|---|
| **Simple** | Returns a single record | Basic — one server |
| **Weighted** | Splits traffic by percentage | Canary deployments (10% to new, 90% to old) |
| **Latency-based** | Routes to the lowest-latency region | Global apps — users go to nearest region |
| **Failover** | Primary/secondary — routes to secondary if primary is unhealthy | Disaster recovery |
| **Geolocation** | Routes based on user's country/continent | Legal requirements, localisation |
| **Geoproximity** | Routes based on distance, with bias adjustment | Fine-grained geographic control |
| **IP-based** | Routes based on client's IP CIDR | ISP or corporate network routing |
| **Multi-value** | Returns multiple values (like DNS load balancing) | Simple load spreading |

## 13.6 Health checks

Route 53 can monitor your endpoints and automatically route traffic away from unhealthy ones:

```bash
aws route53 create-health-check \
  --caller-reference 2024-01-15-001 \
  --health-check-config '{
    "IPAddress": "54.72.140.23",
    "Port": 80,
    "Type": "HTTP",
    "ResourcePath": "/health",
    "FailureThreshold": 3,
    "RequestInterval": 30
  }'
```

Combined with **Failover routing policy**: if the primary endpoint fails its health check, Route 53 automatically switches DNS to point to the secondary endpoint (e.g. a static error page in S3, or a different region).

## 13.7 Using Route 53 with your ECS project

For the ECS capstone project:

1. Register a domain in Route 53 (or transfer an existing one)
2. Create a public hosted zone for the domain
3. Request an ACM certificate for the domain
4. Create an ALB and attach the ACM certificate to port 443 listener
5. Create an Alias record in Route 53 pointing your domain to the ALB DNS name
6. Result: `https://yourdomain.com` → ALB → ECS tasks

```bash
# Create an alias record pointing your domain to an ALB
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890 \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "www.example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "my-alb.eu-west-2.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'
```

---

# Chapter 14 — CloudFront: Content Delivery Network

## 14.1 What is CloudFront?

**CloudFront** is AWS's CDN (Content Delivery Network). It caches content at edge locations around the world — so users download assets from the nearest edge location rather than your origin server.

```
User in Tokyo
  → Nearest CloudFront edge (Tokyo)
  → Returns cached asset (milliseconds)
  (Only on cache miss: edge fetches from your origin server in London)
```

Benefits:
- **Lower latency** — users get content from nearby edge
- **Reduced origin load** — static assets served from cache, not your server
- **DDoS protection** — CloudFront absorbs traffic before it reaches your origin
- **HTTPS everywhere** — easily add HTTPS to any origin
- **Cost reduction** — data transferred via CloudFront is cheaper than EC2 outbound transfer

## 14.2 CloudFront origins

What CloudFront fetches from and caches:

| Origin type | Example |
|---|---|
| **S3 bucket** | Static website, images, videos |
| **ALB** | Your dynamic web application |
| **EC2 instance** | Direct to instance (less common) |
| **HTTP server** | Any HTTP endpoint |

## 14.3 CloudFront with S3

The most common pattern: S3 hosts static files, CloudFront delivers them globally.

```
User → CloudFront → S3 bucket (origin)
```

Use **Origin Access Control (OAC)** so only CloudFront can access the S3 bucket — not the public internet:

1. Create an S3 bucket (block all public access)
2. Create a CloudFront distribution pointing to the S3 bucket
3. Enable OAC — CloudFront signs requests to S3
4. Update the S3 bucket policy to allow CloudFront's OAC principal
5. Result: users can only access files through CloudFront, not directly from S3

## 14.4 CloudFront with ALB

For dynamic content, CloudFront sits in front of your ALB:

```
User → CloudFront → ALB → ECS tasks
```

CloudFront caches API responses where appropriate (with cache control headers) and provides an edge layer for your application.

---

# Chapter 15 — AWS CLI Reference for the Module

All the commands you'll use throughout the AWS module:

## Account and identity

```bash
aws configure                           # set up credentials and region
aws configure list                      # show current configuration
aws configure list-profiles             # show all configured profiles
aws sts get-caller-identity             # who am I? (account ID, user ARN)
aws iam list-users                      # list all IAM users
aws iam get-user                        # get current user details
aws iam create-user --user-name alice   # create a user
aws iam create-group --group-name Devs  # create a group
aws iam add-user-to-group --group-name Devs --user-name alice
aws iam list-attached-user-policies --user-name alice
```

## EC2

```bash
aws ec2 describe-instances              # list all instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running"  # running only
aws ec2 run-instances \
  --image-id ami-0abc123 \
  --instance-type t3.micro \
  --key-name my-key \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678 \
  --count 1
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
aws ec2 start-instances --instance-ids i-1234567890abcdef0
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
aws ec2 describe-security-groups
aws ec2 describe-key-pairs
```

## VPC and networking

```bash
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-internet-gateways
aws ec2 describe-route-tables
aws ec2 describe-nat-gateways
aws ec2 describe-network-acls
aws ec2 describe-addresses              # Elastic IPs
```

## S3

```bash
aws s3 ls                               # list all buckets
aws s3 ls s3://my-bucket/              # list bucket contents
aws s3 cp file.txt s3://my-bucket/     # upload a file
aws s3 cp s3://my-bucket/file.txt .   # download a file
aws s3 sync ./local-dir s3://bucket/  # sync directory
aws s3 rm s3://my-bucket/file.txt     # delete a file
aws s3 mb s3://my-new-bucket          # create a bucket
aws s3 rb s3://my-bucket --force      # delete a bucket and all contents
```

## ECS and ECR

```bash
aws ecr create-repository --repository-name myapp
aws ecr describe-repositories
aws ecr get-login-password --region eu-west-2 | \
  docker login --username AWS --password-stdin \
  ACCOUNT.dkr.ecr.eu-west-2.amazonaws.com
aws ecs list-clusters
aws ecs list-services --cluster my-cluster
aws ecs describe-services \
  --cluster my-cluster --services my-service
aws ecs list-tasks --cluster my-cluster
aws ecs describe-tasks \
  --cluster my-cluster --tasks TASK_ARN
```

## Route 53

```bash
aws route53 list-hosted-zones
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890
```

---

# Chapter 16 — Quick Reference Cheat Sheet

## Global infrastructure

```
Region → multiple AZs (3–6 per region) → data centres within an AZ
Points of Presence (400+) → CloudFront edge locations

Region naming: eu-west-2 (London), eu-west-1 (Ireland), us-east-1 (N. Virginia)
Choose region: latency + data residency + service availability + price
```

## IAM summary

```
User     → one person or system, has credentials
Group    → collection of users, attach policies here
Policy   → JSON: Effect + Action + Resource. Deny overrides Allow.
Role     → assumed by services or accounts, temporary credentials

Root account: MFA + never use for daily work
Least privilege: minimum permissions needed
Access keys: rotate + never commit to code
```

## EC2 summary

```
AMI → operating system image
Instance type: t3.micro (free tier), m5.large (general), c5 (compute), r5 (memory)
User Data: bootstrap script, runs as root on first boot
Key pair: .pem file, chmod 400, ssh -i key.pem ec2-user@IP
Security group: virtual firewall, stateful, allow only

Purchasing:
  On-Demand: pay per second, no commitment
  Reserved:  1-3 year, up to 72% savings
  Spot:      spare capacity, up to 90% savings, can be interrupted
```

## VPC summary

```
VPC: your private network in AWS (e.g. 10.0.0.0/16)
Public subnet:  has route to IGW → resources can have public IPs
Private subnet: no direct internet → use NAT Gateway for outbound

Internet Gateway (IGW): connects VPC to internet
NAT Gateway: outbound internet for private subnets (in public subnet, charged)
Bastion host: SSH jump box in public subnet to reach private resources
Security group: instance-level stateful firewall
NACL: subnet-level stateless firewall (allow + deny)
VPC Peering: connect two VPCs (non-transitive)
VPC Endpoint: private access to AWS services without internet
```

## Load balancing and scaling

```
ALB (Application LB): Layer 7, URL/header routing, for web apps
NLB (Network LB): Layer 4, TCP/UDP, high performance
Target Group: the backend servers an LB routes to
Health check: /health endpoint, HTTP 200 = healthy
Auto Scaling Group: min/max/desired, scales on CloudWatch alarms
Scaling policies: target tracking, step, scheduled, predictive
```

## Containers

```
ECR: private Docker registry (push/pull images)
ECS: AWS container orchestration
  Task Definition: container blueprint (image, CPU, memory, ports, role)
  Service: runs N tasks, integrates with ALB, rolling deploys
  Cluster: group of resources
  EC2 launch: you manage nodes
  Fargate: AWS manages nodes (serverless containers)
EKS: managed Kubernetes
```

## Route 53

```
Hosted zone: DNS container for a domain
Alias record: points to AWS resources (ALB, CloudFront) — free queries
A record: name → IPv4 address
CNAME: name → another name

Routing policies:
  Simple:        one record
  Weighted:      percentage split (canary deployments)
  Latency:       nearest region
  Failover:      primary/secondary
  Geolocation:   by country
  Multi-value:   multiple returns
```

---

# Appendix — Interview Questions

**1. What is AWS and why do companies use it?**
The leading cloud platform — rent computing, storage, and hundreds of managed services on demand. Pay per use, scale instantly, no upfront hardware investment. ~47% market share.

**2. What is an Availability Zone and why does it matter?**
A physically separate data centre cluster within a region. Spreading across AZs means one data centre failing doesn't take down your service — the foundation of high availability.

**3. What is IAM and what are its four main components?**
Identity and Access Management — controls who can do what in AWS. Users (people/systems), Groups (collections of users), Policies (JSON permissions), Roles (temporary credentials for services).

**4. What is the least privilege principle?**
Give any user or service only the minimum permissions needed to do their specific job. Nothing more. Limits the blast radius if credentials are compromised.

**5. What's the difference between an IAM user and an IAM role?**
A user has permanent credentials (password or access keys). A role has no permanent credentials — it's assumed and provides temporary credentials. Use roles for AWS services, not access keys.

**6. What is a security group?**
A stateful virtual firewall at the instance level. By default blocks all inbound, allows all outbound. You add allow rules for specific ports and sources. Return traffic is automatically allowed (stateful).

**7. What is the difference between a public and private subnet?**
A public subnet has a route to an internet gateway — instances can have public IPs. A private subnet has no direct internet route — instances are only reachable within the VPC. Use NAT Gateway for outbound internet from private subnets.

**8. What is a NAT Gateway?**
Allows instances in private subnets to initiate outbound connections to the internet without being directly reachable from the internet. Lives in a public subnet, has an Elastic IP.

**9. What is the difference between ALB and NLB?**
ALB (Application Load Balancer) works at Layer 7 (HTTP) — can route based on URL, headers, host. NLB (Network Load Balancer) works at Layer 4 (TCP/UDP) — higher performance, preserves source IP.

**10. What is ECS and what is Fargate?**
ECS is AWS's container orchestration service — manages Docker containers on AWS. Fargate is a serverless compute engine for ECS — you don't manage EC2 instances; AWS handles all the underlying infrastructure.

**11. What is the difference between ECS and EKS?**
ECS is AWS-proprietary container orchestration — simpler, AWS-native. EKS is managed Kubernetes — the open standard, more complex, portable across clouds.

**12. What is a VPC endpoint?**
A private connection from your VPC to an AWS service (like S3 or DynamoDB) without traffic going over the internet. Improves security and reduces data transfer costs.

**13. What is Route 53's Alias record?**
An AWS-specific DNS record type that points to AWS resources (ALBs, CloudFront, S3 websites) by DNS name rather than IP. Updates automatically when the resource's IP changes. Free for queries targeting AWS resources.

**14. What is CloudFront?**
AWS's CDN. Caches content at 400+ edge locations worldwide. Reduces latency by serving content from the nearest edge. Reduces origin load. Adds DDoS protection.

**15. What are the three ways to access AWS?**
Management Console (browser), AWS CLI (terminal), AWS SDK (programmatic — boto3 for Python, etc.).
