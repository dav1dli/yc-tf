resource "yandex_mdb_postgresql_cluster" "main" {
  name        = "pg-cluster"
  network_id  = yandex_vpc_network.main.id
  environment = "DEVELOPMENT"
  description = "Managed Service for PostgreSQL cluster"
  labels = {
    environment = lower(var.environment)
  }
  config {
    version = "16"
    resources {
      resource_preset_id = "s2.micro"
      disk_size          = 20
      disk_type_id       = "network-ssd"
    }
    postgresql_config = {
      max_connections                   = 395
      enable_parallel_hash              = true
      autovacuum_vacuum_scale_factor    = 0.34
      default_transaction_isolation     = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries          = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }
  host {
    zone           = "ru-central1-a"
    subnet_id      = yandex_vpc_subnet.main.id
    assign_public_ip = false
  }
}

resource "yandex_mdb_postgresql_database" "app_db" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = "app_db"
  owner      = yandex_mdb_postgresql_user.app_admin.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "uuid-ossp"
  }
  extension {
    name = "xml2"
  }
}
resource "random_password" "app_admin_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
  min_upper = 2
  min_lower = 2
  min_numeric = 2
  min_special = 2
  keepers = {
    resource_id = yandex_mdb_postgresql_cluster.main.id
  }
}
resource "yandex_mdb_postgresql_user" "app_admin" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = "app_admin"
  password   = random_password.app_admin_password.result
  grants = ["ALL"]
  permission {
    database_name = "app_db"
  }
}
resource "random_password" "app_write_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
  min_upper = 2
  min_lower = 2
  min_numeric = 2
  min_special = 2
  keepers = {
    resource_id = yandex_mdb_postgresql_cluster.main.id
  }
}
resource "yandex_mdb_postgresql_user" "app_write_user" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = "app_write_user"
  password   = random_password.app_write_password.result
  grants = ["WRITE"]
  permission {
    database_name = "app_db"
  }
}
resource "random_password" "app_read_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric  = true
  min_upper = 2
  min_lower = 2
  min_numeric = 2
  min_special = 2
  keepers = {
    resource_id = yandex_mdb_postgresql_cluster.main.id
  }
}
resource "yandex_mdb_postgresql_user" "app_read_user" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = "app_read_user"
  password   = random_password.app_read_password.result
  grants = ["READ"]
  permission {
    database_name = "app_db"
  }
}
output "pgcluster_fqdn" {
 value = yandex_mdb_postgresql_cluster.main.host.fqdn
}