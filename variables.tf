variable "project_id" {
  description = "The GCP Project ID where resources will be deployed"
  type        = string
  default     = "cloudtech"
}

variable "region" {
  description = "The region to deploy the GKE cluster into"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The specific zone for the standard zonal cluster"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "ecommerce-vpc"
}

variable "master_cidr_block" {
  description = "CIDR block for the GKE master's private endpoint (must be /28)"
  type        = string
  default     = "172.16.0.0/28"
}
