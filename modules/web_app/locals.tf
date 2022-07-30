locals {
  namespace = "${var.project_slug}-${var.env}"

  gateway = {
    name = "${local.namespace}-gw"
  }

  lambda = {
    name               = "${local.namespace}-lambda"
    layers_arn_web     = ["arn:aws:lambda:${var.region}:209497400698:layer:php-81-fpm:27"]
    layers_arn_artisan = ["arn:aws:lambda:${var.region}:209497400698:layer:php-81:27", "arn:aws:lambda:${var.region}:209497400698:layer:console:58"]
    s3_bucket          = "wf-terraform-test2"
  }

  s3_website_artifact = {
    name = "${local.namespace}-artifact"
  }

  s3_website_assets = {
    name = "${local.namespace}-assets"
  }

  s3_website_storage = {
    name = "${local.namespace}-storage"
  }
}
