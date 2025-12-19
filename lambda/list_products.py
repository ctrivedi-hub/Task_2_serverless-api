"""
Lambda Function: List Products
==============================
Retrieves all products from DynamoDB.

API: GET /products
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
    Main handler for listing all products.
    
    Args:
        event: API Gateway event
        context: Lambda context object
    
    Returns:
        API Gateway response with list of products
    """
    try:
        # Scan the entire table (for demo purposes)
        # Note: For production with large tables, use pagination or Query
        response = table.scan()
        
        items = response.get('Items', [])
        
        # Handle pagination if there are more items
        # DynamoDB returns max 1MB of data per scan
        while 'LastEvaluatedKey' in response:
            response = table.scan(
                ExclusiveStartKey=response['LastEvaluatedKey']
            )
            items.extend(response.get('Items', []))
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'count': len(items),
                'products': items
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

