#===============================================================================
# VARIABLES.TF - Input Variables for Serverless API
#===============================================================================

#-------------------------------------------------------------------------------
# AWS REGION
#-------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

#-------------------------------------------------------------------------------
# PROJECT NAMING
#-------------------------------------------------------------------------------
variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "serverless-api"
}

#-------------------------------------------------------------------------------
# DYNAMODB CONFIGURATION
#-------------------------------------------------------------------------------
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "Products"
}

# Read/Write capacity units for DynamoDB
# For Free Tier: 25 RCU and 25 WCU are free
variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units"
  type        = number
  default     = 5
}

#-------------------------------------------------------------------------------
# LAMBDA CONFIGURATION
#-------------------------------------------------------------------------------
variable "lambda_runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 128
}

