
resource "yandex_vpc_network" "network" {
  description = "Network for the Managed Service for Kubernetes cluster"
  name        = local.vnet_name
  folder_id   = var.folder_id
  labels = {
    environment = var.environment
  }
}
resource "yandex_vpc_subnet" "subnet-mngmt" {
  description    = "Management Subnet in ru-central1-a AZ"
  name           = "subnet-mngmt"
  zone           = var.az_deflt
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [local.az_dflt_mngmt_cidr]
}
#resource "yandex_vpc_subnet" "subnet-pods" {
#  description    = "Pods Subnet in ru-central1-a AZ"
#  name           = "subnet-pods"
#  zone           = "ru-central1-a"
#  network_id     = yandex_vpc_network.network.id
#  v4_cidr_blocks = [local.az_dflt_pods_cidr]
#}
#resource "yandex_vpc_subnet" "subnet-services" {
#  description    = "Services Subnet in ru-central1-a AZ"
#  name           = "subnet-services"
#  zone           = "ru-central1-a"
#  network_id     = yandex_vpc_network.network.id
#  v4_cidr_blocks = [local.az_dflt_svc_cidr]
#}