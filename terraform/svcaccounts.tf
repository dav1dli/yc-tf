data "yandex_resourcemanager_folder" "cloud-folder" {
  folder_id = var.folder_id # Folder ID required for binding roles to service account.
}
resource "yandex_iam_service_account" "sa-resedit" {
  description = "Service account for the Managed Service for Kubernetes resources management"
  name        = local.sa_resedit_name
}
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-resedit.id}"
  ]
}
resource "yandex_iam_service_account" "sa-imgpull" {
  description = "Service account for the Managed Service for Kubernetes CR image pulling"
  name        = local.sa_imgpull_name
}
resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-imgpull.id}"
  ]
}
resource "yandex_iam_service_account" "sa-ic" {
  description = "Service account for the Managed Service for Kubernetes ingress controller"
  name        = local.sa_ic_name
}

resource "yandex_resourcemanager_folder_iam_binding" "alb-editor" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "alb.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ic.id}"
  ]
}
resource "yandex_resourcemanager_folder_iam_binding" "vpc-publicadmin" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ic.id}"
  ]
}
resource "yandex_resourcemanager_folder_iam_binding" "cert-dwnld" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "certificate-manager.certificates.downloader"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ic.id}"
  ]
}
resource "yandex_resourcemanager_folder_iam_binding" "compute-viewer" {
  folder_id = data.yandex_resourcemanager_folder.cloud-folder.id
  role      = "compute.viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-ic.id}"
  ]
}
# Сервисный эккаунт для ингресс контроллера:
# yc iam key create \
#   --service-account-id $IC_SA_ID \
#   --output sa-key.json