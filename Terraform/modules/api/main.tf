# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = var.name
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.invoke
}

############################## GET BLOCK #####################################

resource "aws_api_gateway_method" "request_method_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = var.authorization 
  request_parameters = var.query_params 
  count         = contains(var.method_type,"GET") ? 1 : 0
}

resource "aws_api_gateway_integration" "request_method_integration_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.request_method_get[count.index].http_method
  type        = var.integration
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
  request_parameters = var.integration_query_params 
  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "GET"
  request_templates = {
    "application/json" = ""
  }
  timeout_milliseconds    = var.api_timeout                        
  passthrough_behavior    = "WHEN_NO_TEMPLATES"       
  content_handling        = "CONVERT_TO_TEXT"         
  count                   = contains(var.method_type,"GET") ? 1 : 0
}

resource "aws_api_gateway_method_response" "request_method_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_integration.request_method_integration_get[count.index].http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = {
    "application/json" = "Empty"
  }
  count         = contains(var.method_type,"GET") ? 1 : 0
}

resource "aws_api_gateway_integration_response" "response_method_integration_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method_response.request_method_get[count.index].http_method
  status_code = aws_api_gateway_method_response.request_method_get[count.index].status_code
  response_templates = {
    "application/json" = ""
  }
  count         = contains(var.method_type,"GET") ? 1 : 0
}

resource "aws_lambda_permission" "allow_api_gateway_get" {
  function_name = var.lambda_arn
  statement_id  = "AllowGETExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/${var.invoke}"
  count         = contains(var.method_type,"GET") ? 1 : 0
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy]
}

##############################################################################

############################## POST BLOCK ####################################

resource "aws_api_gateway_method" "request_method_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = var.authorization       
  count         = contains(var.method_type,"POST") ? 1 : 0
}

resource "aws_api_gateway_integration" "request_method_integration_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.request_method_post[count.index].http_method
  type        = var.integration         
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
  request_templates = {
    "application/json" = ""
  }
  timeout_milliseconds    = var.api_timeout                      
  passthrough_behavior    = "WHEN_NO_TEMPLATES"       
  content_handling        = "CONVERT_TO_TEXT"        
  count         = contains(var.method_type,"POST") ? 1 : 0
}


resource "aws_api_gateway_method_response" "request_method_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_integration.request_method_integration_post[count.index].http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = {
    "application/json" = "Empty"
  }
  count         = contains(var.method_type,"POST") ? 1 : 0
}

resource "aws_api_gateway_integration_response" "response_method_integration_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method_response.request_method_post[count.index].http_method
  status_code = aws_api_gateway_method_response.request_method_post[count.index].status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "integration.response.header.Access-Control-Allow-Origin" }
  response_templates = {
    "application/json" = ""
  }
  count         = contains(var.method_type,"POST") ? 1 : 0
}

resource "aws_lambda_permission" "allow_api_gateway_post" {
  function_name = var.lambda_arn
  statement_id  = "AllowPOSTExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/${var.invoke}"
  count         = contains(var.method_type,"POST") ? 1 : 0
  depends_on    = [aws_api_gateway_rest_api.api, aws_api_gateway_resource.proxy]
}

##############################################################################

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
  depends_on  = [aws_api_gateway_integration.request_method_integration_get, aws_api_gateway_integration.request_method_integration_post]
}



