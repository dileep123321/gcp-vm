variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "container_image" {
  description = "Full Container image path (Artifact Registry)"
  type        = string
}

variable "vm_name" {
  type    = string
  default = "fastapi-vm"
}
