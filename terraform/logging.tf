resource "yandex_logging_group" "logs" {
  name      = local.logs_name
  folder_id = var.folder_id
  description = "Logging group"
  labels = {
    environment = var.environment
  }
}