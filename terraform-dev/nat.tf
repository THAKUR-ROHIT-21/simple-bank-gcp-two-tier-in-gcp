resource "google_compute_router" "dev_router" {
  name    = "simple-bank-dev-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.dev_vpc.id
}

resource "google_compute_address" "nat_ip" {
  name         = "simple-bank-dev-nat-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router_nat" "dev_nat" {
  name                               = "simple-bank-dev-nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.dev_router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  min_ports_per_vm = 64

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
