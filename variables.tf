variable "hostname" {
  description = "Domain of the web app"
  type        = string
}

variable "project_slug" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "region" {
  description = "Region where to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "cloudfront_price_class" {
  description = "Cloudfront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "app_env_variables" {
  description = "Environment variables injected in the application"
  type        = map(string)
  default = {
    "APP_DEBUG" = false
  }
}
