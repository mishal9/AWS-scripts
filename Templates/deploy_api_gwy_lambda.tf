module "test" {
  # source = "git@git.mobi.asu.edu:mobile/asumobileapp_architecture?ref=dev"
  source = ".//Terraform"
  # tags
  project = "personal"
  owner   = "ms"

  # lambda
  lambda_source        = "./Lambda/test_lambda"
  lambda_zip_path      = "test_lambda.zip"
  lambda_runtime       = "nodejs12.x"
  lambda_memory        = "256"
  lambda_function_name = "test_lambda"
  lambda_version       = "1.0.0"
  tags                 = {
    feature = "healthcheck_test"
  }

  # vpc
  #vpc_id  = "vpc-0bc7af6827370784b"
  #subnets = [""]

  # API gateway
  region              = "us-west-2"
  timeout             = 28000
  authorization_type  = "AWS_IAM" 
  integration_type    = "AWS" 
  query_params        = {
    "method.request.querystring.some-query-param" = false
  }
  integration_query_params = {
    "integration.request.querystring.newVar" = "method.request.querystring.some-query-param"
  }
  invoke_path         = "test"
  method_type         = ["GET","POST"]
  account_id          = "xxxxxxxxx"
}
