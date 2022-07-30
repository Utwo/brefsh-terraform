resource "aws_apigatewayv2_api" "gw_lambda" {
  name          = local.gateway.name
  description   = "Gateway for ${var.project_slug} lambda function"
  protocol_type = "HTTP"
  tags = {
    Name = var.project_slug
    Env  = var.env
  }
}

resource "aws_apigatewayv2_stage" "gw_stage_lambda" {
  api_id = aws_apigatewayv2_api.gw_lambda.id

  name        = "$default"
  auto_deploy = true

  tags = {
    Name = var.project_slug
    Env  = var.env
  }
}

resource "aws_apigatewayv2_integration" "gw_integration" {
  api_id = aws_apigatewayv2_api.gw_lambda.id

  integration_uri        = aws_lambda_function.lambda.arn
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "gw_route" {
  api_id = aws_apigatewayv2_api.gw_lambda.id

  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.gw_integration.id}"
}

resource "aws_cloudwatch_log_group" "gw_logs" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.gw_lambda.name}"

  retention_in_days = 30

  tags = {
    Name = var.project_slug
    Env  = var.env
  }
}

resource "aws_lambda_permission" "gw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.gw_lambda.execution_arn}/*/*"
}
