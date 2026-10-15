terraform {
  backend "s3" {
    bucket       = "rahman-state-bucket"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true # encrypt state at rest
    use_lockfile = true # for state locking
  }
}
