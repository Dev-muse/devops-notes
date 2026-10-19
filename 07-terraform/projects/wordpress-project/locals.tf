
locals {
  name_prefix = "wordpress-${var.environment}"


  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project="Wordpress-Deployment"
  }
}
 