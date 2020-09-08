module "covid_notifications_api" {
  source = ".//../../../../Terraform/API" 
  # tags

  # API gateway
  lambda_name         = "covid_notifications_test"
  region              = "us-west-2"
  timeout             = 29000
  authorization_type  = "AWS_IAM" 
  integration_type    = "AWS" 
  invoke_path         = "notifications"
  method_type         = ["GET"]
  account_id          = "962004002375"
}