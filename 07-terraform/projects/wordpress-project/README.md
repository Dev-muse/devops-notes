# Automated WordPress Stack on AWS using Terraform

A production-ready Infrastructure as Code (IaC) project that provisions a functional, automated WordPress application stack on AWS (`eu-west-2`) using Terraform, automated database initialization, remote state management, and real-time bootstrap logging.

---

## 🏗️ Architecture Overview

This project uses a monolithic single-instance architecture where all application tiers run on a single Amazon EC2 instance inside a custom Virtual Private Cloud (VPC).

- **Cloud Provider:** AWS (`eu-west-2` / London region)
- **Infrastructure as Code:** Terraform (State locking enabled via S3 remote backend)
- **Networking:**
  - Custom VPC (`10.0.0.0/16`)
  - Public Subnet (`10.0.1.0/24`) with auto-assign public IPv4
  - Internet Gateway (IGW) & Public Route Table
- **Security Group Rules:**
  - Ingress: HTTP (`80`), HTTPS (`443`), SSH (`22`)
  - Egress: Unrestricted outgoing traffic
- **Compute & Web Stack:**
  - **Instance Type:** `t3.micro` (Amazon Linux 2023)
  - **Web Server:** Apache (`httpd`)
  - **Database Engine:** MariaDB 10.5
  - **Runtime:** PHP 8.x with required extensions (`php-mysqlnd`, `php-gd`, `php-mbstring`, `php-xml`, `php-json`)

---

## ⚙️ Key Technical Features & Engineering Solutions

1. **Remote S3 State Management:**
   Terraform state is stored remotely in an AWS S3 bucket (`rahman-state-bucket`), enabling team collaboration, preventing local state divergence, and preserving environment integrity.

2. **Zero-Touch Automated Provisioning (`user-data.sh`):**
   Fully automated installation script executed at EC2 first-boot. It handles package installation, service startup, MariaDB configuration, database user creation, and WordPress deployment without manual intervention.

3. **Database Race Condition Prevention:**
   Implements an automated service polling loop (`mysqladmin ping`) inside the bootstrap script. The script waits for the MariaDB service daemon to fully initialize before running SQL setup commands, eliminating `Error establishing a database connection` issues.

4. **Real-Time Bootstrap Logging:**
   Captures all stdout and stderr output directly on the VM via `exec > >(tee /var/log/wordpress-install.log) 2>&1`. Allows real-time troubleshooting via SSH (`sudo tail -f /var/log/wordpress-install.log`).

5. **Security Best Practices:**
   Private keys (`*.pem`) and local Terraform state files (`.tfstate`) are kept strictly out of source control using localized `.gitignore` rules.

---

## 📁 Repository Structure

```text
.
├── main.tf                 # Core AWS resources (VPC, Subnets, IGW, Security Groups, EC2)
├── backend.tf              # S3 remote state configuration
├── outputs.tf              # Public IP and WordPress access URL outputs
├── user-data.sh            # Automated server bootstrap and provisioning script
├── .gitignore              # Ignores local state, secrets, and private keys (*.pem)
└── README.md               # Project documentation
```
---

## 💡 What I Learnt

- **Infrastructure as Code (IaC):** Modularizing cloud resource provisioning using Terraform and isolating state management via remote AWS S3 backends.
- **Zero-Touch Automation:** Automating application stack deployment (LAMP/LEMP) using cloud-init / EC2 user data scripts.
- **Troubleshooting & Observability:** Leveraging live SSH terminal logging (`/var/log/wordpress-install.log`) and Linux service polling to debug boot-time race conditions.

---

## ⚠️ Issues Hit & How They Were Fixed

1. **Database Race Condition on Boot (`Error establishing a database connection`)**
   - **Problem:** The EC2 user-data script attempted to execute database initialization commands immediately, before the MariaDB daemon had finished initializing on its socket.
   - **Fix:** Added a service polling loop (`while ! mysqladmin ping -h localhost --silent; do sleep 2; done`) inside `user-data.sh` to block execution until MariaDB is fully alive and ready.

2. **Lost SSH Key Pair (`.pem`)**
   - **Problem:** The local SSH key was deleted/misplaced during testing, blocking remote terminal debugging.
   - **Fix:** Updated the Terraform `key_name` configuration with a newly generated key pair and re-applied the plan, allowing secure access while keeping infrastructure code in sync.
---

## 🚀 Deployment Instructions

### Prerequisites
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) installed locally.
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid administrator credentials.
- An existing S3 bucket (`rahman-state-bucket`) for storing remote state.

### Step 1: Initialize Terraform
Initialize working directory, download provider plugins, and configure the remote backend:
```bash
terraform init
```

### Step 2: Review Deployment Plan
Inspect the resources Terraform will provision:
```bash
terraform plan
```

### Step 3: Deploy Infrastructure
Apply the configuration:
```bash
terraform apply
```
Type `yes` when prompted.

### Step 4: Access WordPress
Once deployment completes, output the public URL:
```bash
terraform output wordpress_url
```
Navigate to the provided URL in your browser to complete the standard 5-minute WordPress web setup.

---

## 📸 Screenshots & Proof of Deployment

### 1. WordPress Database Credentials Setup
*Initial configuration page verifying database connection parameters (`wordpress_db`, `amuse123`).*

![WordPress Database Setup](https://res.cloudinary.com/dkayhh5lk/image/upload/v1792432274/cred_eligy7.png)

---

### 2. WordPress Initial Installation Process
*WordPress web installer acknowledging a successful database connection and prompting for site details.*

![WordPress Welcome Screen](https://res.cloudinary.com/dkayhh5lk/image/upload/v1792432395/install_akj1w8.png)

---

### 3. Final WordPress Admin Dashboard
*Fully provisioned WordPress admin dashboard running live on AWS infrastructure.*

![WordPress Dashboard](https://res.cloudinary.com/dkayhh5lk/image/upload/v1792432389/dashboard_hdkn8q.png)

---

## 🧹 Teardown

To destroy all provisioned AWS infrastructure and avoid ongoing cloud costs:
```bash
terraform destroy
```
