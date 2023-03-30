resource "yandex_container_registry" "default" {
  name          = var.registry_name
  folder_id     = var.folder_id
}