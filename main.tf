provider "google" {
  credentials = var.cred_file
  project     = var.project
  zone        = var.zone
}

# Create storages
resource "google_compute_disk" "mlflow-data" {
  name        = var.disk_name
  description = "Store for mlflow metrics"
  size        = var.disk_size
  type        = "pd-standard"
  # lifecycle {
  #   prevent_destroy = true
  # }
  labels = {
    data = "mlflow-metrics"
  }
}

resource "google_storage_bucket" "mlflow-models" {
  name                        = "mlflow-models"
  location                    = "US"
  uniform_bucket_level_access = true
  # lifecycle {
  #   prevent_destroy = true
  # }
}


# Create server instance
resource "google_compute_instance" "mlflow-tracking-server" {
  name         = "mlflow-tracking-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  attached_disk { # This is where persistent data live
    device_name = var.disk_name
    mode        = "READ_WRITE"
    source      = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${var.zone}/disks/mlflow-data"
  }

  metadata_startup_script = templatefile("${path.module}/mlflow-tracking-instance-start-up-script.sh",
  { version = var.mlflow_version, password = var.mlflow_password, bucket = var.bucket_name })

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  network_interface {
    network = "default"

    access_config {
      # Include this section to give the VM an external ip address
    }
  }

  depends_on = [
    google_storage_bucket.mlflow-models,
    google_compute_disk.mlflow-data
  ]
}

resource "google_compute_firewall" "default" {
  name    = "mlflow-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
