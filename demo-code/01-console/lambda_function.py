# AWS Lambda Workshop - Part 1: Console Demo
# Copy this code into the AWS Console Lambda editor

import json

def lambda_handler(event, context):
    """
    Simple Lambda handler for Console demonstration.
    This function returns a greeting message with the input event.
    """
    print(f"Event received: {json.dumps(event)}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Console Lambda!',
            'input': event
        })
    }
