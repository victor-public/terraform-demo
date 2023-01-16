variable "target_api" {
  description = "API name"
  type = string
}

data "aws_api_gateway_rest_api" "target_api" {
  name = var.target_api
}
