terraform {
  backend "s3" {
    bucket = "project.tfstates"
    key    = "test_module.tfstate"
    region = "us-west-2"
  }
}
provider "aws" {
  region  = "us-west-2"
}
provider "aws" {
  region = "us-west-2"
  alias = "ops"
}