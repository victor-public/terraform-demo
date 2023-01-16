variable "target_api" {
  description = "API name"
  type = string
}

data "aws_api_gateway_rest_api" "target_api" {
  name = var.target_api
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id

  triggers = {
    redeployment = sha1(timestamp())
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = data.aws_api_gateway_rest_api.target_api.id
  stage_name    = "${var.target_api}-stage"
}
