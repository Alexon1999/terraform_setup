terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.36.0"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  access_key      = var.scw_access_key
  secret_key      = var.scw_secret_key
  organization_id = var.scw_organization_id
  project_id      = var.scw_project_id
  region          = var.scw_region
  zone            = var.scw_zone
}
