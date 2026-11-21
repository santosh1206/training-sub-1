variable "resource_group_name" {
  type    = string
  default = "rg-aks-prod"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "cluster_name" {
  type    = string
  default = "aks-prod-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34.2"
}