variable "account_id" {
  description = "Account ID needed to construct ARN to allow API Gateway to invoke lambda function"
  default = "962004002375"
}

variable "region" {
  description = "Region in which to deploy the API"
  default     = "us-west-2"
}

####################
# Resolver
####################

variable resolver_field {
  description = ""
}

variable resolver_type {
  description = ""
}

variable api_name {
  description = "Name of the API"
}

variable request_template {
  description = "Request template for resolver"
}

variable response_template {
  description = "Response template for resolver"
}

variable table_name {
  description = "Name of the dynamo table source"
  default = ""
}

variable function_name {
  description = "Name of the lambda function source"
  default = ""
}

variable elasticsearch_endpoint {
  description = "Name of the elasticsearch endpoint"
  default = ""
}

variable http_endpoint {
  description = "Name of the http endpoint"
  default = ""
}


####################
# Schema
####################

variable schema {
  description = "Schema for AppSync"
}

####################
# Data source
####################

variable "type" {
  type        = string
  description = "Data source type"
  default     = ""
}

variable "dynamo_config" {
  type        = string
  description = "DynamoDB settings"
  default     = ""
}

variable "elasticsearch_config" {
  type        = string
  description = "AMAZON Elasticsearch settings"
  default     = ""
}

variable "http_config" {
  type        = string
  description = "HTTP settings"
  default     = ""
}

variable "lambda_config" {
  type        = string
  description = "AWS Lambda settings"
  default     = ""
}