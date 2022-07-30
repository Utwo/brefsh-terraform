module "web_app" {
  source = "./modules/web_app"

  # Input Variables
  hostname               = var.hostname
  env                    = var.env
  project_slug           = var.project_slug
  region                 = var.region
  app_env_variables      = var.app_env_variables
  cloudfront_price_class = var.cloudfront_price_class
}
