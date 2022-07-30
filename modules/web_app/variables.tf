variable "hostname" {
  description = "Domain for website the web app"
  type        = string
}

variable "project_slug" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "Region where to deploy resources"
  type        = string
}

variable "cloudfront_price_class" {
  description = "Cloudfront distribution price class"
  type        = string
}

variable "app_env_variables" {
  description = "Environment variables injected in the application"
  type        = map(string)
}
