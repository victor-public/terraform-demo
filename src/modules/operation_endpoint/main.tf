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

resource "aws_iam_role" "lambda_role" {
  name = "role_for_${var.operation}_operation"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "assets/${var.operation}.py"
  output_path = "assets/${var.operation}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "${var.operation}_lambda"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.lambda_role.arn
  handler = "${var.operation}.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_permission" "allow_api_to_use_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${data.aws_api_gateway_rest_api.target_api.execution_arn}/*/*/*"
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
  rest_api_id             = data.aws_api_gateway_rest_api.target_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}
