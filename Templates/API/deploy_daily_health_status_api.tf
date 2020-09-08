module "daily_health_status_api" {
  source = ".//../../../../Terraform/API" 
  # tags

  # API gateway
  lambda_name         = "check_Daily_Health_status_test"
  region              = "us-west-2"
  timeout             = 28000
  authorization_type  = "NONE" 
  integration_type    = "AWS" 
  query_params        = {
    "method.request.querystring.some-query-param" = false
  }
  integration_query_params = {
    "integration.request.querystring.newVar" = "method.request.querystring.some-query-param"
  }
  invoke_path         = "healthchecktest"
  method_type         = ["GET","POST"]
  account_id          = "962004002375"
}