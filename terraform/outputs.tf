output "jumphost_public_ip" {
  value = yandex_compute_instance.jumphost.network_interface.0.nat_ip_address
}