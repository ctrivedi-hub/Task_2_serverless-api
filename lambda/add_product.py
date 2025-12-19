"""
Lambda Function: Add Product
============================
Creates a new product in DynamoDB.

API: POST /product
Body: { "id": "123", "name": "Product Name", "price": 99.99, "description": "..." }
"""

import json
import boto3
import uuid
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Products')


def lambda_handler(event, context):
    """
    Main handler for adding a product.
    
    Args:
        event: API Gateway event containing the request
        context: Lambda context object
    
    Returns:
        API Gateway response with status code and body
    """
    try:
        # Parse the request body
        # API Gateway sends body as string, so we need to parse it
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})
        
        # Generate UUID if id not provided
        product_id = body.get('id', str(uuid.uuid4()))
        
        # Validate required fields
        if 'name' not in body:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing required field: name'
                })
            }
        
        # Create the product item
        # Convert float to Decimal for DynamoDB compatibility
        item = {
            'id': product_id,
            'name': body['name'],
            'price': Decimal(str(body.get('price', 0))),
            'description': body.get('description', ''),
            'category': body.get('category', 'General')
        }
        
        # Put item into DynamoDB
        table.put_item(Item=item)
        
        # Convert Decimal back to float for JSON response
        response_item = {
            'id': item['id'],
            'name': item['name'],
            'price': float(item['price']),
            'description': item['description'],
            'category': item['category']
        }
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Product created successfully',
                'product': response_item
            })
        }
        
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Invalid JSON in request body'
            })
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

