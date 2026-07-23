locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  ssh_metadata = "${var.ssh_user}:${local.ssh_public_key}"
}

resource "google_compute_address" "frontend_public_ip" {
  name         = "simple-bank-dev-frontend-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    google_project_service.required
  ]
}

resource "google_compute_instance" "frontend" {
  name         = "simple-bank-dev-frontend-vm"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.frontend_machine_type

  tags = [
    "simple-bank-dev-frontend"
  ]

  labels = var.labels

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.boot_disk_size_gb
      type  = "pd-balanced"

      labels = var.labels
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.id
    network_ip = var.frontend_private_ip

    access_config {
      nat_ip       = google_compute_address.frontend_public_ip.address
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    ssh-keys               = local.ssh_metadata
    block-project-ssh-keys = "true"
  }

  metadata_startup_script = templatefile(
    "${path.module}/scripts/frontend-startup.sh",
    {
      ssh_user = var.ssh_user
    }
  )

  service_account {
    email = google_service_account.vm_service_account.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true

  depends_on = [
    google_project_service.required,
    google_project_iam_member.logging_writer,
    google_project_iam_member.monitoring_writer
  ]
}

resource "google_compute_instance" "backend" {
  name         = "simple-bank-dev-backend-vm"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.backend_machine_type

  tags = [
    "simple-bank-dev-backend"
  ]

  labels = var.labels

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.boot_disk_size_gb
      type  = "pd-balanced"

      labels = var.labels
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
    network_ip = var.backend_private_ip

    # No access_config block means no external IP.
  }

  metadata = {
    ssh-keys               = local.ssh_metadata
    block-project-ssh-keys = "true"
  }

  metadata_startup_script = templatefile(
    "${path.module}/scripts/backend-startup.sh",
    {
      ssh_user = var.ssh_user
    }
  )

  service_account {
    email = google_service_account.vm_service_account.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true

  depends_on = [
    google_compute_router_nat.dev_nat,
    google_project_iam_member.logging_writer,
    google_project_iam_member.monitoring_writer
  ]
}
