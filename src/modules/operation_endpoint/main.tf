variable "operation" {
  description = "Operation to apply"
  type = string
}

variable "target_api" {
  description = "API name"
  type = string
}

data "aws_api_gateway_rest_api" "target_api" {
  name = var.target_api
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  parent_id   = data.aws_api_gateway_rest_api.target_api.root_resource_id
  path_part   = var.operation
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = data.aws_api_gateway_rest_api.target_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.a" = true,
    "method.request.querystring.b" = true
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id          = data.aws_api_gateway_rest_api.target_api.id
  resource_id          = aws_api_gateway_resource.resource.id
  http_method          = aws_api_gateway_method.method.http_method
  type                 = "MOCK"
  cache_key_parameters = ["method.request.querystring.a", "method.request.querystring.b"]
  cache_namespace      = "${var.operation}-request-cache"
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}
