# Scaleway
variable "scw_access_key" {
  type        = string
  description = "Your Scaleway Access Key."
  sensitive   = true
}

variable "scw_secret_key" {
  type        = string
  description = "Your Scaleway Secret Key."
  sensitive   = true
}

variable "scw_organization_id" {
  type        = string
  description = "Your organization ID."
  sensitive   = true
}

variable "scw_project_id" {
  type        = string
  description = "Your project ID."
  sensitive   = true
}

variable "scw_region" {
  type        = string
  description = "Your Region."
}

variable "scw_zone" {
  type        = string
  description = "Your Zone."
}


# Project
variable "project_name" {
  type        = string
  description = "Your project Name."
}

variable "environment" {
  type        = string
  description = "Your Environment Name."
}


# Instance

variable "backend_instance_type" {
  default = "PLAY2-NANO"
  type    = string
}


variable "backend_instance_root_volume_size_in_gb" {
  default = 10
  type    = number
}


variable "frontend_instance_type" {
  default = "PLAY2-NANO"
  type    = string
}

variable "frontend_instance_root_volume_size_in_gb" {
  default = 10
  type    = number
}

# Database

variable "db_instance_node_type" {
  default = "DB-PLAY2-PICO"
  type    = string
}

variable "db_instance_volume_size_in_gb" {
  default = 10
  type    = number
}

variable "db_instance_admin_user_name" {
  type = string
}

variable "db_instance_admin_password" {
  type = string
}

variable "db_instance_database_name" {
  type = string
}

variable "db_instance_user_name" {
  type = string
}

variable "db_instance_password" {
  type = string
}


# Load Balancer

variable "lb_type" {
  default = "LB-S"
  type    = string
}

variable "lb_backend_backend_port" {
  default = 8080
  type    = number
}

variable "lb_frontend_port" {
  default = 80
  type    = number
}

# DNS

variable "domain_name" {
  type = string
}

variable "subdomain_name" {
  type = string
}

variable "backend_dns_record_name" {
  type = string
}

variable "frontend_dns_record_name" {
  type = string
}
