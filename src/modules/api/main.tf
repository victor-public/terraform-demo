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

resource "aws_api_gateway_documentation_part" "document_api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  location {
    type   = "API"
  }

  properties  = jsonencode({
    info = {
      description = "A generic description of the API"
      termsOfService = "Link to this API terms of Service"
      contact = {
        name = "Contact name"
        url = "www.this-api-docs.com"
        email = "contact@mail.com"
      }
      license = {
        name = "This API's license"
        url = "www.this-api-license.com"
      }
    }
  })
}

resource "aws_api_gateway_api_key" "key" {
  name = "${var.name}-key"
}
