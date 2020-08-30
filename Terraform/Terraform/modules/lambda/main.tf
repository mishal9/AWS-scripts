locals {
  environment_map = var.environment_vars == null ? [] : [var.environment_vars]
}
resource "aws_lambda_function" "lambda" {
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  function_name    = var.function_name
  role             = var.role
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = var.memory
  source_code_hash = var.hash
  tags             = var.tags
  dynamic "environment" {
    for_each = local.environment_map
    content {
      variables = environment.value
    }
  }
  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = "${filebase64sha256("lambda_function_payload.zip")}"
  
  #vpc_config {
  #  subnet_ids         = "${var.subnet_ids}"
  #  security_group_ids = "${var.security_group_ids}"
  #}
  
  
}
