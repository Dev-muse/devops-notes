terraform {
  backend "s3" {
    bucket       = "rahman-state-bucket"
    key          = "wordpress-app/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true

  }
}
