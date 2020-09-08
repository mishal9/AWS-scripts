module "appsync" {
  source                       = "../modules/appsync"
  schema                       = var.schema
  api_name                     = var.api_name
  account_id                   = var.account_id
  table_name                   = var.table_name
  function_name                = var.function_name
  elasticsearch_endpoint       = var.elasticsearch_endpoint
  http_endpoint                = var.http_endpoint
  resolver_field               = var.resolver_field
  resolver_type                = var.resolver_type
  request_template             = var.request_template
  response_template            = var.response_template
  type                         = var.type
}