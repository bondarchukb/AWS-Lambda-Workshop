# AWS Lambda Workshop - Part 2: CLI Demo
# Deploy this function using AWS CLI

import json
from datetime import datetime, timezone

def lambda_handler(event, context):
    """
    Lambda handler for CLI deployment demonstration.
    Returns a message with timestamp.
    """
    print(f"Event received: {json.dumps(event)}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from CLI Lambda!',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'input': event
        })
    }
