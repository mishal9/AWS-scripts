terraform {
  backend "s3" {
    bucket = "jenkins.tfstates"
    key    = "covid_terraform_lambda.tfstate"
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