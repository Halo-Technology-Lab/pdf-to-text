provider "aws" {
  region = "us-east-1" # Change to your desired region
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda-function"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  filename = "lambda_function.zip"

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      ENV_VAR = "example"
    }
  }
}

resource "aws_apigatewayv2_api" "example_api" {
  name          = "example-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id               = aws_apigatewayv2_api.example_api.id
  integration_type     = "AWS_PROXY"
  integration_uri      = aws_lambda_function.example_lambda.arn
  passthrough_behavior = "WHEN_NO_MATCH"

  depends_on = [aws_lambda_function.example_lambda]
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.example_api.id
  route_key = "POST /"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.example_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.example_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.example_api.api_endpoint
}
