module "daily_health_status_lambda" {
  # source = "git@git.mobi.asu.edu:mobile/asumobileapp_architecture?ref=dev"
  source = ".//../../../../Terraform/Lambda" 
  # lambda
  lambda_source        = "daily_health_check"
  lambda_zip_path      = "check_Daily_Health_status_test.zip"
  lambda_runtime       = "nodejs12.x"
  lambda_memory        = "256"
  lambda_function_name = "check_Daily_Health_status_test"
  lambda_version       = "1.0.0"
  tags                 = {
    feature = "healthcheck_test"
  }

  # vpc
  #vpc_id  = "vpc-0bc7af6827370784b"
  #subnets = [""]

}

