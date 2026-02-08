# AWS Lambda Workshop - Part 4: SAM Lambda Handler

import json
from datetime import datetime, timezone


def lambda_handler(event, context):
    """
    Lambda handler for SAM demonstration.
    Handles both GET and POST requests from API Gateway.
    """
    http_method = event.get('httpMethod', 'UNKNOWN')
    path = event.get('path', '/')

    # Parse body if present (for POST requests)
    body = {}
    if event.get('body'):
        try:
            body = json.loads(event['body'])
        except json.JSONDecodeError:
            body = {'raw': event['body']}

    response_body = {
        'message': 'Hello from SAM Lambda!',
        'method': http_method,
        'path': path,
        'timestamp': datetime.now(timezone.utc).isoformat(),
    }

    # Include POST body in response if present
    if body:
        response_body['received_data'] = body

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(response_body)
    }
