# resource "yandex_compute_instance" "jumphost" {
#   name        = local.jumphost_name
#   platform_id = "standard-v3"
#   zone        = var.az_deflt

#   resources {
#     cores  = 2
#     memory = 4
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "fd8i3uauimpm750kd9vh"
#     }
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.subnet-mngmt.id
#     nat       = true
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/yctf_id_ed25519.pub")}"
#   }
#   labels = {
#     environment       = lower(var.environment)
#   }
# }

# output "jumphost_public_ip" {
#   value = yandex_compute_instance.jumphost.network_interface.0.nat_ip_address
# }