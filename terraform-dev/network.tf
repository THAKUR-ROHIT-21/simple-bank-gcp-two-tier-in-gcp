resource "google_compute_network" "dev_vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [
    google_project_service.required
  ]
}

resource "google_compute_subnetwork" "public" {
  name          = var.public_subnet_name
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.dev_vpc.id
  ip_cidr_range = var.public_subnet_cidr

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private" {
  name          = var.private_subnet_name
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.dev_vpc.id
  ip_cidr_range = var.private_subnet_cidr

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
