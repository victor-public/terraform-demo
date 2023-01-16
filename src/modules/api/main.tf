variable "name" {
  description = "API name"
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.name
  description = "An API for demonstration purposes"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_api_key" "key" {
  name = "${var.name}-key"
}
