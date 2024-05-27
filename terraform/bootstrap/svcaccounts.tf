data "yandex_resourcemanager_folder" "cloud-folder" {
  folder_id = var.folder_id # Folder ID required for binding roles to service account.
}
resource "yandex_iam_service_account" "sa-s3tf-edit" {
  description = "Service account for the Managed Service for Kubernetes resources management"
  name        = local.sa_s3tf_name
}
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-s3tf-edit.id}"
}
resource "yandex_lockbox_secret_iam_binding" "lockbox_view" {
  secret_id = yandex_lockbox_secret.oauth-token.id
  role      = "lockbox.payloadViewer"
  members    = ["serviceAccount:${yandex_iam_service_account.sa-s3tf-edit.id}"]
}
resource "yandex_lockbox_secret_iam_binding" "lockbox_edit" {
  secret_id = yandex_lockbox_secret.oauth-token.id
  role      = "lockbox.editor"
  members    = ["serviceAccount:${yandex_iam_service_account.sa-s3tf-edit.id}"]
}
resource "yandex_iam_service_account_static_access_key" "sa-s3tf-static-key" {
  service_account_id = yandex_iam_service_account.sa-s3tf-edit.id
  description        = "static access key for object storage"
}

output "sa-s3tf-access-key" {
  value = yandex_iam_service_account_static_access_key.sa-s3tf-static-key.access_key
  sensitive = true
}
output "sa-s3tf-secret-key" {
  value = yandex_iam_service_account_static_access_key.sa-s3tf-static-key.secret_key
  sensitive = true 
}