provider "aws" {
  region = "eu-west-1"
}

locals {
  name              = "demo-api"
  description       = "A generic description of the API"
  terms_of_service  = "Link to this API Terms Of Service page"
  contact           = {
    name  = "Contact name"
    url   = "www.this-api-docs.com"
    email = "contact@mail.com"
  }
  license           = {
    name  = "This API's license"
    url   = "www.this-api-license.com"
  }
  endpoints         = [
    {operation: "sum", description: "Sums two numbers"},
    /* ADD AS MANY SUPPORTED OPERATIONS AS YOU WANT:
    {operation: "mul", description: "Multiplies two numbers"},
    {operation: "div", description: "Dividess two numbers"},
    {operation: "diff", description: "Substract two numbers"}
    */
  ]
}
