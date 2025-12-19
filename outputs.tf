#===============================================================================
# OUTPUTS.TF - Output Values
#===============================================================================

#-------------------------------------------------------------------------------
# API Gateway Endpoint URL
#-------------------------------------------------------------------------------
output "api_endpoint" {
  description = "Base URL of the API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "add_product_endpoint" {
  description = "Endpoint to add a product (POST)"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/product"
}

output "get_product_endpoint" {
  description = "Endpoint to get a product by ID (GET)"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/product/{id}"
}

output "list_products_endpoint" {
  description = "Endpoint to list all products (GET)"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/products"
}

#-------------------------------------------------------------------------------
# DynamoDB Table
#-------------------------------------------------------------------------------
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.products.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.products.arn
}

#-------------------------------------------------------------------------------
# Lambda Functions
#-------------------------------------------------------------------------------
output "lambda_add_product_arn" {
  description = "ARN of the Add Product Lambda"
  value       = aws_lambda_function.add_product.arn
}

output "lambda_get_product_arn" {
  description = "ARN of the Get Product Lambda"
  value       = aws_lambda_function.get_product.arn
}

output "lambda_list_products_arn" {
  description = "ARN of the List Products Lambda"
  value       = aws_lambda_function.list_products.arn
}

#-------------------------------------------------------------------------------
# Test Commands
#-------------------------------------------------------------------------------
output "test_commands" {
  description = "Commands to test the API"
  value       = <<-EOT

    ============================================================
    🎉 SERVERLESS API DEPLOYED! Test with these commands:
    ============================================================

    📌 1. Add a product (POST):
    curl -X POST ${aws_api_gateway_stage.prod.invoke_url}/product \
      -H "Content-Type: application/json" \
      -d '{"id":"1","name":"Laptop","price":999.99,"description":"Gaming laptop"}'

    📌 2. Add another product:
    curl -X POST ${aws_api_gateway_stage.prod.invoke_url}/product \
      -H "Content-Type: application/json" \
      -d '{"id":"2","name":"Mouse","price":49.99,"description":"Wireless mouse"}'

    📌 3. Get a product by ID (GET):
    curl ${aws_api_gateway_stage.prod.invoke_url}/product/1

    📌 4. List all products (GET):
    curl ${aws_api_gateway_stage.prod.invoke_url}/products

    📌 5. To destroy all resources:
    terraform destroy

    ============================================================
    
  EOT
}

