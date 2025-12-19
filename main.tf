#===============================================================================
# MAIN.TF - Serverless API Infrastructure
#===============================================================================
# This file creates:
# - DynamoDB Table (Products)
# - IAM Role & Policy for Lambda
# - Lambda Functions (Add, Get, List)
# - API Gateway (REST API)
# - API Gateway Routes & Integrations
#===============================================================================

#===============================================================================
# SECTION 1: TERRAFORM & PROVIDER CONFIGURATION
#===============================================================================

terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#===============================================================================
# SECTION 2: DYNAMODB TABLE
#===============================================================================
# DynamoDB is a fully managed NoSQL database.
# We create a simple table with 'id' as the primary key (partition key).

resource "aws_dynamodb_table" "products" {
  name           = var.dynamodb_table_name  # "Products"
  billing_mode   = "PROVISIONED"            # Use provisioned capacity (Free Tier)
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "id"                     # Primary key (partition key)

  # Define the primary key attribute
  attribute {
    name = "id"
    type = "S"  # S = String, N = Number, B = Binary
  }

  tags = {
    Name        = "${var.project_name}-products-table"
    Environment = "demo"
  }
}

#===============================================================================
# SECTION 3: IAM ROLE FOR LAMBDA
#===============================================================================
# Lambda needs an IAM role to:
# 1. Be invoked by API Gateway
# 2. Access DynamoDB
# 3. Write logs to CloudWatch

# IAM Role - The identity that Lambda assumes
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  # Trust policy - Who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-role"
  }
}

# IAM Policy - What the role can do
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudWatch Logs permissions
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        # DynamoDB permissions for the Products table
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.products.arn
      }
    ]
  })
}

#===============================================================================
# SECTION 4: PACKAGE LAMBDA FUNCTIONS
#===============================================================================
# Terraform's archive provider creates zip files from our Python code.

data "archive_file" "add_product_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/add_product.py"
  output_path = "${path.module}/lambda/add_product.zip"
}

data "archive_file" "get_product_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/get_product.py"
  output_path = "${path.module}/lambda/get_product.zip"
}

data "archive_file" "list_products_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/list_products.py"
  output_path = "${path.module}/lambda/list_products.zip"
}

#===============================================================================
# SECTION 5: LAMBDA FUNCTIONS
#===============================================================================

#-------------------------------------------------------------------------------
# Lambda: Add Product
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "add_product" {
  filename         = data.archive_file.add_product_zip.output_path
  function_name    = "${var.project_name}-add-product"
  role             = aws_iam_role.lambda_role.arn
  handler          = "add_product.lambda_handler"  # filename.function_name
  source_code_hash = data.archive_file.add_product_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.products.name
    }
  }

  tags = {
    Name = "${var.project_name}-add-product"
  }
}

#-------------------------------------------------------------------------------
# Lambda: Get Product
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "get_product" {
  filename         = data.archive_file.get_product_zip.output_path
  function_name    = "${var.project_name}-get-product"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_product.lambda_handler"
  source_code_hash = data.archive_file.get_product_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.products.name
    }
  }

  tags = {
    Name = "${var.project_name}-get-product"
  }
}

#-------------------------------------------------------------------------------
# Lambda: List Products
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "list_products" {
  filename         = data.archive_file.list_products_zip.output_path
  function_name    = "${var.project_name}-list-products"
  role             = aws_iam_role.lambda_role.arn
  handler          = "list_products.lambda_handler"
  source_code_hash = data.archive_file.list_products_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.products.name
    }
  }

  tags = {
    Name = "${var.project_name}-list-products"
  }
}

#===============================================================================
# SECTION 6: API GATEWAY (REST API)
#===============================================================================
# API Gateway creates HTTP endpoints that trigger Lambda functions.

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "Serverless Products API"

  endpoint_configuration {
    types = ["REGIONAL"]  # Regional endpoint (vs Edge-optimized)
  }

  tags = {
    Name = "${var.project_name}-api"
  }
}

#-------------------------------------------------------------------------------
# API Resource: /product
#-------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "product"
}

#-------------------------------------------------------------------------------
# API Resource: /product/{id}
#-------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "product_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.product.id
  path_part   = "{id}"  # Path parameter
}

#-------------------------------------------------------------------------------
# API Resource: /products (for listing all)
#-------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "products"
}

#===============================================================================
# SECTION 7: API GATEWAY METHODS & INTEGRATIONS
#===============================================================================

#-------------------------------------------------------------------------------
# POST /product - Add Product
#-------------------------------------------------------------------------------
resource "aws_api_gateway_method" "post_product" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "POST"
  authorization = "NONE"  # No auth for demo (use API Key or Cognito in production)
}

resource "aws_api_gateway_integration" "post_product" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.post_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"  # Lambda Proxy integration
  uri                     = aws_lambda_function.add_product.invoke_arn
}

#-------------------------------------------------------------------------------
# GET /product/{id} - Get Product by ID
#-------------------------------------------------------------------------------
resource "aws_api_gateway_method" "get_product" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.product_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_product" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.product_id.id
  http_method             = aws_api_gateway_method.get_product.http_method
  integration_http_method = "POST"  # Lambda always uses POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_product.invoke_arn
}

#-------------------------------------------------------------------------------
# GET /products - List All Products
#-------------------------------------------------------------------------------
resource "aws_api_gateway_method" "list_products" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_products" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = aws_api_gateway_method.list_products.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_products.invoke_arn
}

#===============================================================================
# SECTION 8: LAMBDA PERMISSIONS FOR API GATEWAY
#===============================================================================
# Allow API Gateway to invoke our Lambda functions

resource "aws_lambda_permission" "add_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "list_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

#===============================================================================
# SECTION 9: API GATEWAY DEPLOYMENT
#===============================================================================
# Deploy the API to make it accessible

resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_integration.post_product,
    aws_api_gateway_integration.get_product,
    aws_api_gateway_integration.list_products
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  # Force new deployment when integrations change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.product.id,
      aws_api_gateway_resource.product_id.id,
      aws_api_gateway_resource.products.id,
      aws_api_gateway_method.post_product.id,
      aws_api_gateway_method.get_product.id,
      aws_api_gateway_method.list_products.id,
      aws_api_gateway_integration.post_product.id,
      aws_api_gateway_integration.get_product.id,
      aws_api_gateway_integration.list_products.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"

  tags = {
    Name = "${var.project_name}-prod-stage"
  }
}

