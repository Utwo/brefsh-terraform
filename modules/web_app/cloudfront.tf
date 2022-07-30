locals {
  gateway_origin_id    = aws_lambda_function.lambda.function_name
  s3_origin_assets_id  = "origin_assets"
  s3_origin_favicon_id = "origin_favicon"
  s3_origin_robots_id  = "origin_robots"
}

resource "aws_cloudfront_distribution" "distribution" {
  comment     = "Cloudfront distribution for ${var.project_slug}."
  price_class = var.cloudfront_price_class
  aliases     = [var.hostname]

  origin {
    domain_name = replace(aws_apigatewayv2_stage.gw_stage_lambda.invoke_url, "/^https?://([^/]*).*/", "$1")
    origin_id   = local.gateway_origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_assets.bucket_regional_domain_name
    origin_id   = local.s3_origin_assets_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity_assets.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_assets.bucket_regional_domain_name
    origin_id   = local.s3_origin_favicon_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity_assets.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_assets.bucket_regional_domain_name
    origin_id   = local.s3_origin_robots_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity_assets.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    target_origin_id         = local.gateway_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.cloudfront_cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.cloudfront_request_policy.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.cloudfront_function_add_header.arn
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "/assets/*"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    target_origin_id       = local.s3_origin_assets_id
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "/favicon.ico"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    target_origin_id       = local.s3_origin_favicon_id
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "/robots.txt"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    target_origin_id       = local.s3_origin_robots_id
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  tags = {
    Name = var.project_slug
    Env  = var.env
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 500
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 504
  }
}

resource "aws_cloudfront_function" "cloudfront_function_add_header" {
  name    = "${local.namespace}-request"
  runtime = "cloudfront-js-1.0"
  comment = "Add x-forwarded-host header"
  publish = true
  code    = file("${path.module}/function.js")
}

resource "aws_cloudfront_cache_policy" "cloudfront_cache_policy" {
  name        = "${local.namespace}-cache"
  comment     = "Cache policy for ${var.project_slug}"
  default_ttl = 0
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization"]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "cloudfront_request_policy" {
  name    = "${local.namespace}-policy"
  comment = "request policy for website factor"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Accept", "X-XSRF-TOKEN", "Referer", "User-Agent", "X-Forwarded-Host", "Accept-Language", "X-INERTIA", "Content-Type"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_origin_access_identity" "access_identity_assets" {
  comment = "Assets access identity"
}
