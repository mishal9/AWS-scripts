provider "aws" {
  region = var.region
}

####################
# Roles
####################
resource "aws_iam_role" "example" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

####################
# GraphQL API with Schema
####################
resource "aws_appsync_graphql_api" "test" {
  authentication_type = "API_KEY"
  name                = var.api_name
  schema              = var.schema
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_appsync_datasource" "noneData" {
  count            = var.type == "NONE" ? 1 : 0
  api_id           = aws_appsync_graphql_api.test.id
  name             = var.api_name
  service_role_arn = aws_iam_role.example.arn
  type             = var.type
}

resource "aws_appsync_resolver" "none_type" {
  api_id            = aws_appsync_graphql_api.test.id
  field             = var.resolver_field
  type              = var.resolver_type
  data_source       = aws_appsync_datasource.noneData[count.index].name
  request_template  = var.request_template
  response_template = var.response_template
  count             = var.type == "NONE" ? 1 : 0
}

resource "aws_appsync_datasource" "dynamoData" {
  count            = var.type == "AMAZON_DYNAMODB" ? 1 : 0
  api_id           = aws_appsync_graphql_api.test.id
  name             = var.api_name
  service_role_arn = aws_iam_role.example.arn
  type             = var.type
  dynamodb_config {
    table_name       = var.table_name
  }
}

resource "aws_appsync_resolver" "dynamo_type" {
  count       = var.type == "AMAZON_DYNAMODB" ? 1 : 0
  api_id      = aws_appsync_graphql_api.test.id
  field       = var.resolver_field
  type        = var.resolver_type
  data_source = aws_appsync_datasource.dynamoData[count.index].name
  request_template = var.request_template
  response_template = var.response_template
}

resource "aws_appsync_datasource" "lambdaData" {
  count            = var.type == "AWS_LAMBDA" ? 1 : 0
  api_id           = aws_appsync_graphql_api.test.id
  name             = var.api_name
  service_role_arn = aws_iam_role.example.arn
  type             = var.type
  lambda_config {
    function_arn   = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.function_name}"
  }
}

resource "aws_appsync_resolver" "lambda_type" {
  count       = var.type == "AWS_LAMBDA" ? 1 : 0
  api_id      = aws_appsync_graphql_api.test.id
  field       = var.resolver_field
  type        = var.resolver_type
  data_source = aws_appsync_datasource.lambdaData[count.index].name
  request_template = var.request_template
  response_template = var.response_template
}

resource "aws_appsync_datasource" "esData" {
  count            = var.type == "AMAZON_ELASTICSEARCH" ? 1 : 0
  api_id           = aws_appsync_graphql_api.test.id
  name             = var.api_name
  service_role_arn = aws_iam_role.example.arn
  type             = var.type
  elasticsearch_config {
    endpoint       = var.elasticsearch_endpoint
  }
}

resource "aws_appsync_resolver" "es_type" {
  count       = var.type == "AMAZON_ELASTICSEARCH" ? 1 : 0
  api_id      = aws_appsync_graphql_api.test.id
  field       = var.resolver_field
  type        = var.resolver_type
  data_source = aws_appsync_datasource.esData[count.index].name
  request_template = var.request_template
  response_template = var.response_template
}

resource "aws_appsync_datasource" "httpData" {
  count            = var.type == "HTTP" ? 1 : 0
  api_id           = aws_appsync_graphql_api.test.id
  name             = var.api_name
  service_role_arn = aws_iam_role.example.arn
  type             = var.type
  http_config {
    endpoint       = var.http_endpoint
  }
}

resource "aws_appsync_resolver" "http_type" {
  count       = var.type == "HTTP" ? 1 : 0
  api_id      = aws_appsync_graphql_api.test.id
  field       = var.resolver_field
  type        = var.resolver_type
  data_source = aws_appsync_datasource.httpData[count.index].name
  request_template = var.request_template
  response_template = var.response_template
}






