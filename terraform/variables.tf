variable "environment" {
  type = string  
  description = "Environment"  
  default = ""
}

variable "project" {
  type = string  
  description = "Application project"  
  default = ""
}
variable "cloud_id" {
  type = string  
  description = "VPC id"  
  default = ""
}
variable "folder_id" {
  type = string  
  description = "folder id"  
  default = ""
}
variable "az_deflt" {
  type = string  
  description = "Default availability zone"  
  default = ""
}
variable "registry_name" {
  type = string  
  description = "Container registry name"  
  default = ""
}
variable "yc_oauth_token" {
  type = string  
  description = "Yaandex Cloud OAuth token"  
  default = ""
  sensitive   = true
}
variable "endpoint" {
  description = "S3 endpoint"
  type        = string
  default     = "https://storage.yandexcloud.net"
}

variable "bucket" {
  description = "The name of the bucket"
  type        = string
  default     = "s3tfstate"
}

variable "key" {
  description = "The path to the state file inside the bucket"
  type        = string
  default     = "infra.tfstate"
}

variable "region" {
  description = "The region of the bucket"
  type        = string
  default     = "ru-central1"
}

variable "access_key" {
  description = "Access key for the S3 backend"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Secret key for the S3 backend"
  type        = string
  sensitive   = true
}