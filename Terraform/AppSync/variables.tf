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

variable request_template {
  description = "Request template for resolver"
  default = ""
}

variable response_template {
  description = "Response template for resolver"
  default = ""
}

variable api_name {
  description = "Name of the API"
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

variable "type" {
  type        = string
  description = "Data source type"
  default     = ""
}

####################
# Schema
####################

variable schema {
  description = "Schema for AppSync"
}