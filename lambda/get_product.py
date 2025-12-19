"""
Lambda Function: Get Product
============================
Retrieves a single product from DynamoDB by ID.

API: GET /product/{id}
"""

import json
import boto3
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Products')


# Helper class to convert Decimal to float for JSON serialization
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


def lambda_handler(event, context):
    """
    Main handler for getting a product by ID.
    
    Args:
        event: API Gateway event containing path parameters
        context: Lambda context object
    
    Returns:
        API Gateway response with the product or error
    """
    try:
        # Get product ID from path parameters
        # API Gateway passes path parameters in event['pathParameters']
        path_params = event.get('pathParameters', {})
        
        if not path_params or 'id' not in path_params:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing product ID in path'
                })
            }
        
        product_id = path_params['id']
        
        # Get item from DynamoDB
        response = table.get_item(
            Key={
                'id': product_id
            }
        )
        
        # Check if item exists
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': f'Product with ID {product_id} not found'
                })
            }
        
        # Return the product
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'product': response['Item']
            }, cls=DecimalEncoder)
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")  # This goes to CloudWatch Logs
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': f'Internal server error: {str(e)}'
            })
        }

