# Store terraform state on Scaleway S3-compatible object storage
terraform {
  backend "s3" {
    bucket                      = "demo-terraform-state"
    key                         = "terraform.tfstate"
    region                      = "fr-par"
    endpoint                    = "https://s3.fr-par.scw.cloud"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}
