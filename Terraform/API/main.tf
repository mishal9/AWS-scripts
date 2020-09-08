module "api" {
  name                      = var.lambda_name
  source                    = "../modules/api"
  #lambda                    = module.lambda.name
  #lambda_arn                = module.lambda.arn
  lambda_name               = var.lambda_name
  region                    = var.region
  account_id                = var.account_id
  authorization             = var.authorization_type
  query_params              = var.query_params
  integration_query_params  = var.integration_query_params
  integration               = var.integration_type
  stage_name                = "dev"
  api_timeout               = var.timeout
  method_type               = flatten([var.method_type])
  invoke                    = var.invoke_path
  count                     = var.invoke_path != "" ? 1 : 0
}