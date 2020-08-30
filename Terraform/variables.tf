####################
# Tags
####################
variable "project" {
  description = "Project name for tags and resource naming"
}

variable "owner" {
  description = "Contact person responsible for the resource"
}
####################
# VPC
####################

variable vpc_id {
  description = "VPC Identifier"
  default = ""
}

variable subnets {
  description = "Subnet IDs associated with lambda"
  default = ""
}

####################
# Lambda
####################
variable "lambda_runtime" {
  description = "Lambda Function runtime"
}

variable "lambda_zip_path" {
  description = "Lambda Function Zipfile local path for S3 Upload"
}

variable "lambda_source" {
  description = "Lambda source"
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
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


####################
# API Gateway
####################
variable "region" {
  description = "Region in which to deploy the API"
  default     = "us-west-2"
}

variable "timeout" {
  description = "Define timepout for API gateway"
  default     = ""
}

variable "authorization_type" {
  description = "Define authorization type for API gateway"
  default     = ""
}

variable "account_id" {
  description = "Account ID needed to construct ARN to allow API Gateway to invoke lambda function"
  default = "962004002375"
}

variable "query_params" {
  description = "Query string parameters for GET requests"
  type    = map(string)
  default = {}
}

variable "integration_query_params" {
  description = "Query string parameters for GET integration requests"
  type    = map(string)
  default = {}
}

variable "invoke_path" {
  description = "Path to invoke API"
  default     = ""
}

variable "integration_type" {
  description = "API gateway integration type"
  default     = ""
}

variable "method_type" {
  description = "API gateway method type (GET/POST/OPTIONS)"
  default     = ""
}