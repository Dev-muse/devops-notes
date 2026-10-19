# ── 1. Custom VPC ─────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })

}

#Internet gateway connects vpc to internet 
# ── 2. Internet Gateway ───────────────────────────────────────────────────────
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-igw" })

}

# ── 3. Public Subnet ──────────────────────────────────────────────────────────
resource "aws_subnet" "Public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-subnet" })
}

# ── 4. Custom Route Table & Association ───────────────────────────────────────

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-rt" })

}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.public_rt.id
}

# ── 5. Security Group (Attached to our custom VPC) ────────────────────────────

resource "aws_security_group" "wordpress_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Allow inbound web and SSH traffic for WordPress"
  vpc_id      = aws_vpc.main.id # Tied to our custom VPC, not default


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}


# ── 6. EC2 Instance (Placed inside our custom public subnet) ──────────────────

resource "aws_instance" "wordpress_server" {
  ami                         = "ami-06cdac14c9c4da91b" # Amazon Linux 2023 in eu-west-2
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.Public.id # References our custom subnet directly
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  associate_public_ip_address = true
  key_name                    = "terraform-test-new"


  user_data = templatefile("${path.module}/user-data.sh", {})

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-instance" })
}
