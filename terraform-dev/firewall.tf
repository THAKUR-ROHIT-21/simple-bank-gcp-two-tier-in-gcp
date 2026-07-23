# SSH from your computer to frontend VM.
resource "google_compute_firewall" "frontend_ssh" {
  name    = "simple-bank-dev-allow-frontend-ssh"
  project = var.project_id
  network = google_compute_network.dev_vpc.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.admin_cidr]
  target_tags   = ["simple-bank-dev-frontend"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Public HTTP and HTTPS traffic to frontend VM.
resource "google_compute_firewall" "frontend_web" {
  name    = "simple-bank-dev-allow-web"
  project = var.project_id
  network = google_compute_network.dev_vpc.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["simple-bank-dev-frontend"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Frontend VM can SSH into private backend VM.
resource "google_compute_firewall" "backend_ssh" {
  name    = "simple-bank-dev-allow-backend-ssh"
  project = var.project_id
  network = google_compute_network.dev_vpc.name

  direction   = "INGRESS"
  priority    = 1000
  source_tags = ["simple-bank-dev-frontend"]
  target_tags = ["simple-bank-dev-backend"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Frontend can reach backend API.
resource "google_compute_firewall" "backend_api" {
  name    = "simple-bank-dev-allow-backend-api"
  project = var.project_id
  network = google_compute_network.dev_vpc.name

  direction   = "INGRESS"
  priority    = 1000
  source_tags = ["simple-bank-dev-frontend"]
  target_tags = ["simple-bank-dev-backend"]

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
}

# Internal diagnostic communication.
resource "google_compute_firewall" "internal_icmp" {
  name    = "simple-bank-dev-allow-internal-icmp"
  project = var.project_id
  network = google_compute_network.dev_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr
  ]

  allow {
    protocol = "icmp"
  }
}
