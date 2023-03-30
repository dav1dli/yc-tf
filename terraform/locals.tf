locals {
  vnet_name          = "vnet-${var.project}-${var.environment}"
  registry_name      = "cr"
  az_deflt           = "ru-central1-a"
  az_dflt_mngmt_cidr = "10.1.0.0/24"
  az_dflt_pods_cidr  = "10.10.0.0/16"
  az_dflt_svc_cidr   = "10.20.0.0/16"
  sa_resedit_name    = "sa-k8s-res-edit"
  sa_imgpull_name    = "sa-k8s-img-pull"
  sa_ic_name         = "sa-k8s-ic"
  k8s_name           = "kube"
  k8s_version        = "1.23"
  jumphost_name      = "jumphost"
}