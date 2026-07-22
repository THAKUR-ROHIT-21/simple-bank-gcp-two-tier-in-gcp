data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "frontend" {
  name         = "simple-bank-${var.environment}-frontend-vm"
  machine_type = var.frontend_machine_type
  zone         = var.zone
  tags         = ["simple-bank-frontend"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 15
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.frontend.id
    network_ip = var.frontend_private_ip

    access_config {
      nat_ip = google_compute_address.frontend.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${trimspace(file(var.ssh_public_key_path))}"
  }

  metadata_startup_script = templatefile(
    "${path.module}/startup/docker-startup.sh.tftpl",
    {
      ssh_user = var.ssh_user
      role     = "frontend"
    }
  )

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_router_nat.main]
}

resource "google_compute_instance" "backend" {
  name         = "simple-bank-${var.environment}-backend-vm"
  machine_type = var.backend_machine_type
  zone         = var.zone
  tags         = ["simple-bank-backend"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 15
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.backend.id
    network_ip = var.backend_private_ip
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${trimspace(file(var.ssh_public_key_path))}"
  }

  metadata_startup_script = templatefile(
    "${path.module}/startup/docker-startup.sh.tftpl",
    {
      ssh_user = var.ssh_user
      role     = "backend"
    }
  )

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_router_nat.main]
}
