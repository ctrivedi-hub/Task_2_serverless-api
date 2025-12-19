#===============================================================================
# TERRAFORM.TFVARS - Variable Values
#===============================================================================

# AWS Region - Mumbai
aws_region = "ap-south-1"

# Project name prefix
project_name = "serverless-api"

# DynamoDB Configuration
dynamodb_table_name    = "Products"
dynamodb_read_capacity  = 5
dynamodb_write_capacity = 5

# Lambda Configuration
lambda_runtime = "python3.9"
lambda_timeout = 30
lambda_memory  = 128

