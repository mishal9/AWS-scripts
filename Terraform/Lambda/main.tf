module "lambda" {
  source             = "../modules/lambda"
  s3_bucket          = "lambda-repo-uto-dev"
  function_name      = var.lambda_function_name
  lambda_source      = var.lambda_source
  lambda_zip_path    = var.lambda_zip_path
  lambda_version     = var.lambda_version
  handler            = "index.handler"
  runtime            = var.lambda_runtime
  memory             = var.lambda_memory
  tags               = var.tags
  variables          = var.variables
  count              = var.lambda_source != "" ? 1 : 0
  dynamo_trigger     = var.dynamo_trigger
  schedule_expression= var.schedule_expression
  #subnet_ids         = flatten(["${var.subnets}"])
  #security_group_ids = flatten(["${aws_security_group.all.id}"])
}
