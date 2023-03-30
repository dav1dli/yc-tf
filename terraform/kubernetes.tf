resource "yandex_kubernetes_cluster" "k8s-cluster" {
  description = "Managed Service for Kubernetes cluster"
  name        = local.k8s_name
  network_id  = yandex_vpc_network.network.id

  master {
    version = local.k8s_version
    zonal {
      zone      = yandex_vpc_subnet.subnet-mngmt.zone
      subnet_id = yandex_vpc_subnet.subnet-mngmt.id
    }

    public_ip = true

  }
  service_account_id      = yandex_iam_service_account.sa-resedit.id # Cluster service account ID.
  node_service_account_id = yandex_iam_service_account.sa-imgpull.id # Node group service account ID.
  labels = {
    environment       = lower(var.environment)
  }
  release_channel = "REGULAR"
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {
  description = "Node group for the Managed Service for Kubernetes cluster"
  name        = "${local.k8s_name}-node-group"
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  version     = local.k8s_version

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.subnet-mngmt.zone
    }
  }

  instance_template {
    platform_id = "standard-v3" # Intel Cascade Lake

    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.subnet-mngmt.id]
    #   security_group_ids = [yandex_vpc_security_group.k8s-main-sg.id]
    }

    resources {
      memory = 4 # GB
      cores  = 2 # Number of CPU cores.
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }
    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }
}
