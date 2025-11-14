terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Service account (VM) - used by the VM to pull images (no JSON keys)
resource "google_service_account" "vm_sa" {
  account_id   = "${var.vm_name}-sa"
  display_name = "VM Service Account"
}

# Grant artifactregistry.reader to the VM service account so it can pull images
resource "google_project_iam_member" "sa_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

# Firewall to allow HTTP 8000
resource "google_compute_firewall" "allow_app" {
  name    = "${var.vm_name}-allow-8000"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.vm_name}-tag"]
}

# Compute Instance
resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["${var.vm_name}-tag"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    CONTAINER_IMAGE = var.container_image
    PROJECT_ID      = var.project_id
  }
}

output "vm_public_ip" {
  description = "Public IP of the VM"
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
