# AWS Lambda Workshop - Part 3: CDK Lambda Handler

import json
from datetime import datetime, timezone

def handler(event, context):
    """
    Lambda handler for CDK deployment demonstration.
    Integrated with API Gateway.
    """
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'Hello from CDK Lambda!',
            'path': event.get('path', '/'),
            'method': event.get('httpMethod', 'UNKNOWN'),
            'timestamp': datetime.now(timezone.utc).isoformat()
        })
    }
