resource "google_compute_network" "main" {
  name                    = "simple-bank-${var.environment}-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

resource "google_compute_subnetwork" "frontend" {
  name                     = "simple-bank-${var.environment}-frontend-subnet"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.frontend_subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "backend" {
  name                     = "simple-bank-${var.environment}-backend-subnet"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.backend_subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_address" "frontend" {
  name   = "simple-bank-${var.environment}-frontend-ip"
  region = var.region
}

resource "google_compute_address" "nat" {
  name   = "simple-bank-${var.environment}-nat-ip"
  region = var.region
}

resource "google_compute_router" "main" {
  name    = "simple-bank-${var.environment}-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  name                               = "simple-bank-${var.environment}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.backend.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "frontend_http" {
  name          = "simple-bank-${var.environment}-allow-http"
  network       = google_compute_network.main.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["simple-bank-frontend"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "frontend_ssh" {
  name          = "simple-bank-${var.environment}-allow-frontend-ssh"
  network       = google_compute_network.main.name
  source_ranges = var.allowed_ssh_cidrs
  target_tags   = ["simple-bank-frontend"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "backend_api" {
  name        = "simple-bank-${var.environment}-allow-backend-api"
  network     = google_compute_network.main.name
  source_tags = ["simple-bank-frontend"]
  target_tags = ["simple-bank-backend"]

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
}

resource "google_compute_firewall" "backend_ssh" {
  name        = "simple-bank-${var.environment}-allow-backend-ssh"
  network     = google_compute_network.main.name
  source_tags = ["simple-bank-frontend"]
  target_tags = ["simple-bank-backend"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
