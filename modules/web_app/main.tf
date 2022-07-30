# To avoid replacement, you need to import the resource:
# terraform import random_password.db_pass securepassword
resource "random_password" "app_key" {
  length  = 32
  special = true

  lifecycle {
    ignore_changes = [
      length,
      special,
      override_special
    ]
  }
}
