variable "name" {
  description = "The name of the REST API"
}

variable "stage_name" {
  description = "The stage name for the API deployment (production/staging/etc..)"
}

variable "method_type" {
  description = "The HTTP method"
}

variable "invoke" {
  description = "Path to invoke"
}

variable "lambda" {
  description = "The lambda name to invoke"
}

variable "api_timeout" {
  description = "Define timeout for API gateway"
}

variable "authorization" {
  description = "API authorization mechanism"
}

variable "integration" {
  description = "API integration mechanism"
}

variable "query_params" {
  description = "Query string parameters for GET requests"
  type    = map(string)
}

variable "integration_query_params" {
  description = "Query string parameters for GET integration requests"
  type    = map(string)
}

variable "lambda_arn" {
  description = "The lambda arn to invoke"
}

variable "region" {
  description = "The AWS region, e.g., eu-west-1"
  default     = "us-west-2"
}

variable "account_id" {
  description = "The AWS account ID"
}
