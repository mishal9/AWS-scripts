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

variable "lambda_name" {
  description = "Associated lambda"
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
