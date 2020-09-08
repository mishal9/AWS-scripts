####################
# Lambda
####################
variable "lambda_runtime" {
  description = "Lambda Function runtime"
  default = ""
}

variable "lambda_zip_path" {
  description = "Lambda Function Zipfile local path for S3 Upload"
  default = ""
}

variable "lambda_source" {
  description = "Lambda source"
  default = ""
}

variable "schedule_expression" {
  description = "Cloudwatch event rule cron"
  default = ""
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
  default = ""
}

variable "dynamo_trigger" {
  description = "DynamoDB trigger"
  default = ""
}

variable "lambda_memory" {
  description = "Lambda memory size, 128 MB to 3,008 MB, in 64 MB increments"
  default     = "128"
}

variable "lambda_version" {
  description = "Version of lambda to be deployed"
  default     = "1.0.0"
}

variable "tags" {
  description = "Tags for resource"
  type    = map(string)
  default = {}
}

variable "variables" {
  description = "Environment variables for lambda"
  type    = map(string)
  default = {}
}

variable "has_variables" {
  type        = string
  description = "true or false"
  default     = false
}