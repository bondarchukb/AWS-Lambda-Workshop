# AWS Lambda Workshop - Part 3: CDK Stack Definition
# Copy this to workshop_cdk/workshop_cdk_stack.py after running cdk init

from aws_cdk import (
    Stack,
    Duration,
    CfnOutput,
    aws_lambda as _lambda,
    aws_apigateway as apigw,
)
from constructs import Construct


class WorkshopCdkStack(Stack):
    """
    CDK Stack for AWS Lambda Workshop.
    Creates a Lambda function with API Gateway integration.
    """

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create Lambda Function
        # The 'lambda' folder contains our handler.py file
        fn = _lambda.Function(
            self, 'WorkshopFunction',
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler='handler.handler',  # filename.function_name
            code=_lambda.Code.from_asset('lambda'),  # folder name
            memory_size=256,
            timeout=Duration.seconds(10),
            environment={
                'ENVIRONMENT': 'workshop'
            }
        )

        # Create API Gateway
        # proxy=True means all requests go to Lambda
        api = apigw.LambdaRestApi(
            self, 'WorkshopApi',
            handler=fn,
            proxy=True,
        )

        # Output the API URL so we can test it
        CfnOutput(
            self, 'ApiUrl',
            value=api.url,
            description='API Gateway URL - use this to test your Lambda',
        )
