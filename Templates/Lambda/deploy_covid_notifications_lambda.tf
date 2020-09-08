module "covid_notifications_lambda" {
  # source = "git@git.mobi.asu.edu:mobile/asumobileapp_architecture?ref=dev"
  source = ".//../../../../Terraform/Lambda" 
  # lambda
  lambda_source        = "covid_notifications"
  lambda_zip_path      = "covid_notifications_test.zip"
  lambda_runtime       = "nodejs12.x"
  lambda_memory        = "256"
  lambda_function_name = "covid_notifications_test"
  lambda_version       = "1.0.0"
  tags                 = {
    feature = "healthcheck_test-3"
  }
  # TODO: IAM policy
  
  # vpc
  #vpc_id  = "vpc-0bc7af6827370784b"
  #subnets = [""]
  dynamo_trigger      = "covid_campus_schedule"
}

