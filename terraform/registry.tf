resource "yandex_container_registry" "default" {
  name          = var.registry_name
  labels = {
    environment = lower(var.environment)
  }
}
resource "yandex_container_registry_ip_permission" "cr_ip_permission" {
  registry_id = yandex_container_registry.default.id
  push        = [local.az_dflt_mngmt_cidr]
  # pull        = [ "10.1.0.0/16", "10.5.0/16" ]
}