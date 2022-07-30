resource "aws_s3_bucket" "website_artifact" {
  bucket = local.s3_website_artifact.name

  tags = {
    Name = var.project_slug
    Env  = var.env
  }

  force_destroy = true
}

resource "aws_s3_bucket_acl" "website_artifact_acl" {
  bucket = aws_s3_bucket.website_artifact.id
  acl    = "private"
}

resource "aws_s3_object" "lambda_artifact" {
  bucket = aws_s3_bucket.website_artifact.id

  key    = "latest.zip"
  source = "${path.root}/latest.zip"

  etag = filemd5("${path.root}/latest.zip")
}

resource "aws_s3_bucket" "website_assets" {
  bucket = local.s3_website_assets.name

  tags = {
    Name = var.project_slug
    Env  = var.env
  }
}

data "aws_iam_policy_document" "s3_assets_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_assets.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_identity_assets.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_assets_policy" {
  bucket = aws_s3_bucket.website_assets.id
  policy = data.aws_iam_policy_document.s3_assets_policy_document.json
}

resource "aws_s3_bucket" "website_storage" {
  bucket = local.s3_website_storage.name

  tags = {
    Name = var.project_slug
    Env  = var.env
  }
}
