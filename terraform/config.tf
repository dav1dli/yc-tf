terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  # backend "s3" {
  #   endpoints = {
  #     s3 = "https://storage.yandexcloud.net"
  #   }
  #   bucket                      = "s3tfstate"
  #   key                         = "terraform.tfstate"
  #   region                      = "ru-central1"
  #   access_key                  = "YCAJELW8fC9GgxGz5FYX6NJuH"
  #   secret_key                  = "YCPBcZYUvJ8L-lLTm2kt17e_-14YJB32QZmzKQJk"
  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true
  #   skip_s3_checksum            = true
  # }
}

provider "yandex" {
  zone = "ru-central1-a"
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  token = var.yc_oauth_token
}
provider "random" {}