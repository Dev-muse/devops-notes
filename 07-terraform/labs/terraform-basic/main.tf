

# Look up your existing subnets in the default VPC
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = ["vpc-060dba94e420c655a"] # Your default VPC ID 
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP inbound traffic"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0c8aa1e36dcf7997a"
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.existing.ids[0] # Pick the first available subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true # This forces AWS to assign an external IP
  key_name = "terraform-test"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Terraform, first EC2 instance!</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "web-server"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}