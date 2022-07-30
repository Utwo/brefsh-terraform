resource "aws_iam_role" "iam_for_lambda" {
  name        = "${local.namespace}_iam_for_lambda"
  description = "Serverless function for ${var.project_slug}."
  tags = {
    Name = var.project_slug
    Env  = var.env
  }
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "${local.namespace}_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a wf lambda"
  tags = {
    Name = var.project_slug
    Env  = var.env
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${local.lambda.name}"

  retention_in_days = 30
  tags = {
    Name = var.project_slug
    Env  = var.env
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

resource "aws_lambda_function" "lambda" {
  function_name = local.lambda.name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "public/index.php"
  layers        = local.lambda.layers_arn_web
  runtime       = "provided.al2"
  s3_bucket     = aws_s3_bucket.website_artifact.id
  s3_key        = aws_s3_object.lambda_artifact.key
  memory_size   = 1024
  timeout       = 28

  tags = {
    Name = var.project_slug
    Env  = var.env
  }

  environment {
    variables = var.app_env_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_log_group
  ]
}

resource "aws_lambda_function" "lambda_artisan" {
  function_name = "${local.lambda.name}-artisan"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "artisan"
  layers        = local.lambda.layers_arn_artisan
  runtime       = "provided.al2"
  s3_bucket     = aws_s3_bucket.website_artifact.id
  s3_key        = aws_s3_object.lambda_artifact.key
  memory_size   = 1024
  timeout       = 120

  tags = {
    Name = var.project_slug
    Env  = var.env
  }

  environment {
    variables = merge({ APP_ENV = var.env }, { APP_KEY = random_password.app_key.result }, var.app_env_variables)
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_log_group
  ]
}
