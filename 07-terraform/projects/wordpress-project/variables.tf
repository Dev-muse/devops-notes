variable "aws_region" {
  type = string
  description = "AWS region we will deploy to"
  default = "eu-west-2" 
}

variable "environment" {
  type = string
  description = "deployment environment name"
  default = "production"
  
}

variable "instance_type" {
  description = "ec2 instance size"
  type = string
  default = "t3.micro"
  
}

variable "key_name" {
  description = "name of the existing ssh key pair in AWs"
  type = string
  default = "terraform-test"
  
}