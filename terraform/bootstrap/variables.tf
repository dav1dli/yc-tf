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
variable "yc_oauth_token" {
  type = string  
  description = "Yaandex Cloud OAuth token"  
  default = ""
  sensitive   = true
}