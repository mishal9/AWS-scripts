####################
# VPC
####################
resource "aws_security_group" "all" {
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}

####################
# API
####################
module "api" {
  name                      = module.lambda.name
  source                    = "./modules/api"
  lambda                    = module.lambda.name
  lambda_arn                = module.lambda.arn
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

####################
# Lambda
####################

# Zip the Lamda function on the fly
data "archive_file" "source" {
  type        = "zip"
  source_dir  = var.lambda_source
  output_path = var.lambda_zip_path
}

# upload zip to s3 and then update lamda function from s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "lambda-repo-uto-dev"
  key    = "v${var.lambda_version}/${var.lambda_zip_path}"
  source = data.archive_file.source.output_path # its mean it depended on zip
}

module "lambda" {
  source             = "./modules/lambda"
  s3_bucket          = "lambda-repo-dev"
  s3_key             = aws_s3_bucket_object.file_upload.key
  function_name      = var.lambda_function_name
  handler            = "index.handler"
  runtime            = var.lambda_runtime
  role               = "<create_role_for_this>"
  memory             = var.lambda_memory
  tags               = var.tags
  variables          = var.variables
  hash               = base64sha256(data.archive_file.source.output_path)
  #subnet_ids         = flatten(["${var.subnets}"])
  #security_group_ids = flatten(["${aws_security_group.all.id}"])
}

