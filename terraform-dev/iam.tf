resource "google_service_account" "vm_service_account" {
  project      = var.project_id
  account_id   = "simple-bank-dev-vm"
  display_name = "Simple Bank DEV VM Service Account"

  depends_on = [
    google_project_service.required
  ]
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}
