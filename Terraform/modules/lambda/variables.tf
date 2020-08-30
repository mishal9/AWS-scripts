variable "function_name" {
  description = "The name of the lambda function"
}

variable "runtime" {
  description = "The runtime of the lambda to create"
}

variable "s3_bucket" {
  description = "Dist s3 bucket"
}

variable "s3_key" {
  description = "The filename of the lambda zip in s3 bucket"
}

variable "hash" {
  description = "The file hash"
}

variable "handler" {
  description = "The handler name of the lambda function"
}

variable "memory" {
  description = "The memory size of the lambda function"
}

variable "role" {
  description = "IAM role attached to the Lambda Function (ARN)"
}

variable "tags" {
  description = "Tags for resource"
  type    = map(string)
}

variable "environment" {
  type        = map
  description = "The Lambda environment's configuration settings. Fields documented below"
  default     = {}
}

variable "environment_vars" {
  type    = map(string)
  default = null
}

variable "variables" {
  type        = map
  description = "A map that defines environment variables for the Lambda function."
  default     = {}
}


#variable "subnet_ids" {
#  description = "Which subnets to associate with lambda"
#}

#variable "security_group_ids" {
#  description = "Which security groups to associate with lambda"
#}
