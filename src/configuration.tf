provider "aws" {
  region = "eu-west-1"
}

locals {
  name = "demo-api"
  endpoints = [
    {operation: "sum", description: "Sums two numbers"},
    /* ADD AS MANY SUPPORTED OPERATIONS AS YOU WANT:
    {operation: "mul", description: "Multiplies two numbers"},
    {operation: "div", description: "Dividess two numbers"},
    {operation: "diff", description: "Substract two numbers"}
    */
  ]
}
