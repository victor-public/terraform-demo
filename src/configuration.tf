provider "aws" {
  region = "eu-west-1"
}

locals {
  name = "demo-api"
  endpoints = [
    {operation: "sum", description: "Sums two numbers"},
    {operation: "mul", description: "Multiplies two numbers"}
  ]
}
