resource "yandex_kms_symmetric_key" "k8s_enc_key" {
  name              = local.k8s_enc_key_name
  description       = "Managed Kubernetes service secrets encryption key"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 1 year
#   lifecycle {
#     prevent_destroy = true
#   }
}