# AWS Lambda Workshop - Part 4: SAM Unit Tests

import json
import pytest
from hello_world import app


def test_lambda_handler_get():
    """Test GET request handling."""
    event = {
        'httpMethod': 'GET',
        'path': '/hello',
        'body': None
    }

    response = app.lambda_handler(event, None)

    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert 'message' in body
    assert body['method'] == 'GET'
    assert 'timestamp' in body


def test_lambda_handler_post():
    """Test POST request handling with body."""
    event = {
        'httpMethod': 'POST',
        'path': '/hello',
        'body': json.dumps({'name': 'Test User'})
    }

    response = app.lambda_handler(event, None)

    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['method'] == 'POST'
    assert 'received_data' in body
    assert body['received_data']['name'] == 'Test User'


def test_lambda_handler_cors_headers():
    """Test that CORS headers are present."""
    event = {
        'httpMethod': 'GET',
        'path': '/hello',
        'body': None
    }

    response = app.lambda_handler(event, None)

    assert 'headers' in response
    assert response['headers']['Access-Control-Allow-Origin'] == '*'
    assert response['headers']['Content-Type'] == 'application/json'
