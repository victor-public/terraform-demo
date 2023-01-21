variable "target_api" {
  description = "API name"
  type = string
}

data "aws_api_gateway_rest_api" "target_api" {
  name = var.target_api
}

resource "aws_iam_role" "lambda_role" {
  name                = "role_for_documentation"
  assume_role_policy  = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action: "sts:AssumeRole",
      Principal: {
        Service: "lambda.amazonaws.com"
      },
      Effect: "Allow"
    }]
  })
}

data "archive_file" "zip" {
  type        = "zip"
  output_path = "temp/documentation.zip"
  source {
    content = <<EOF
def lambda_handler(event, context):
  return {
    'statusCode': 200,
    'body': 'ey from code'
  }
EOF
  filename = "documentation.py"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name     = "documentation_lambda"
  filename          = data.archive_file.zip.output_path
  source_code_hash  = data.archive_file.zip.output_base64sha256
  role              = aws_iam_role.lambda_role.arn
  handler           = "documentation.lambda_handler"
  runtime           = "python3.9"
}

resource "aws_lambda_permission" "allow_api_to_use_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.target_api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  parent_id   = data.aws_api_gateway_rest_api.target_api.root_resource_id
  path_part   = "documentation"
}

resource "aws_api_gateway_documentation_part" "document_resource" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id

  location {
    type   = "RESOURCE"
    path   = "/documentation"
  }

  properties  = jsonencode({
    description = "An endpoint to expose the latest version of this API's documentation"
  })
}

resource "aws_api_gateway_method" "method" {
  rest_api_id         = data.aws_api_gateway_rest_api.target_api.id
  resource_id         = aws_api_gateway_resource.resource.id
  http_method         = "GET"
  authorization       = "NONE"
  api_key_required    = false

  request_parameters  = {
    "method.request.querystring.format" = true,
  }
}

resource "aws_api_gateway_documentation_part" "document_param_format" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id

  location {
    type    = "QUERY_PARAMETER"
    path    = "/documentation"
    method  = aws_api_gateway_method.method.http_method
    name    = "format"
  }

  properties  = jsonencode({
    description = "Desired format type: Swagger (swagger) or OpenAPI 3.0 (oas30)"
  })
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.target_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}
