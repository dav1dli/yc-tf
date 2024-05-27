resource "yandex_storage_bucket" "s3tf" {
  access_key = yandex_iam_service_account_static_access_key.sa-s3tf-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-s3tf-static-key.secret_key
  bucket = local.s3tf_name
  max_size = 5368709120
}

output "s3tf-name" {
  value = yandex_storage_bucket.s3tf.bucket
}
output "s3tf-fqdn" {
  value = yandex_storage_bucket.s3tf.bucket_domain_name
}
output "s3tf-access-key" {
  value = yandex_storage_bucket.s3tf.access_key
  sensitive = true
}
output "s3tf-secret-key" {
  value = yandex_storage_bucket.s3tf.secret_key
  sensitive = true
}