# Lab: Basic EC2 Web Server with Terraform and S3 Remote State

## Objective
The goal of this lab was to provision an EC2 web server on AWS using Terraform while maintaining organized, reproducible infrastructure code, implementing secure remote state management, and ensuring proper public network connectivity and SSH access.

## Commands Used

Initialized S3 remote state with native locking:

  ```hcl
  terraform {
    backend "s3" {
      bucket         = "your-state-bucket-name"
      key            = "terraform.tfstate"
      region         = "eu-west-2"
      use_lockfile   = true
    }
  }
  ```

## Retrieved existing VPC subnets dynamically using data sources:

```hcl
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = ["vpc-060dba94e420c655a"]
  }
}
```


## Planned, applied, and verified infrastructure:

```bash

terraform init
terraform plan
terraform apply

```

## Queried instance public IP and tested connectivity:

```bash

aws ec2 describe-instances --instance-ids <instance-id> --query "Reservations[*].Instances[*].PublicIpAddress" --output text
curl http://<public-ip>
ssh -i "terraform-test.pem" ec2-user@<public-ip>

```

### Output

- Successfully provisioned an Amazon Linux 2 (or equivalent) EC2 instance (```hcl t3.micro```) inside an existing VPC subnet.

- Configured a security group allowing inbound traffic on Port 22 (SSH) and Port 80 (HTTP).

- Configured a Public Route Table and attached an Internet Gateway to ensure public IP assignment (```hcl associate_public_ip_address = true ```).

- Deployed an Apache web server via user_data displaying a custom HTML welcome page (``` <h1>Hello from Terraform, first EC2 instance!</h1>```).

- Added an output block for automatic retrieval of the server's public IP address.

## Challenges

- Missing Public IP / Subnet Routing: Initially, the provisioned instance lacked a public IP because the target subnets were associated with a default route table missing an Internet Gateway route.
  - Solution: Created an explicit public route table route for ``` 0.0.0.0/0 ``` targeting the Internet Gateway and explicitly associated the public subnets.

- Instance Replacement on Attribute Changes: Modifying associate_public_ip_address and key_name forced Terraform to perform a destroy-and-replace action on the aws_instance resource, which was successfully handled by state tracking.


## What I Learned

- How to configure native S3 locking (``` use_lockfile = true```) for remote state without needing a DynamoDB table.
- How to mix manually managed AWS networking components (VPC, Subnets, Internet Gateways) with Terraform-managed compute resources.
- The importance of including key names and network parameters in infrastructure code for full reproducibility and disaster recovery.
EOF