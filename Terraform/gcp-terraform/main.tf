terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Optional: Use ADC if gcloud auth application-default login
  # Or set GOOGLE_APPLICATION_CREDENTIALS to your service account JSON
}

resource "google_compute_network" "default" {
  name = "default-network"
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "ubuntu_vm" {
  name         = "ubuntu-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.default.self_link

    access_config {
      # Ephemeral external IP
    }
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
# Update and install packages
apt update -y
apt upgrade -y
EOF
}

