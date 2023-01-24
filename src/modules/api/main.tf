variable "name" {
  description = "API name"
}

variable "description" {
  description = "API's description"
}

variable "terms_of_service" {
  description = "Link to API's terms of service page"
}

variable "license" {
  description = "API's license information"
}

variable "contact" {
  description = "API's contact information"
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.name
  description = "An API for demonstration purposes"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_documentation_part" "document_api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  location {
    type   = "API"
  }

  properties  = jsonencode({
    info = {
      description = var.description
      termsOfService = var.terms_of_service
      contact = var.contact
      license = var.license
    }
  })
}

resource "aws_api_gateway_api_key" "key" {
  name = "${var.name}-key"
}
