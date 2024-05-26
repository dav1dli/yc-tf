resource "yandex_logging_group" "logs" {
  name      = local.logs_name
  description = "Logging group"
  labels = {
    environment = var.environment
  }
}