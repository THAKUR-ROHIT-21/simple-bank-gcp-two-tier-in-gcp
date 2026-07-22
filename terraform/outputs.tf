output "frontend_external_ip" {
  value = google_compute_address.frontend.address
}

output "frontend_private_ip" {
  value = google_compute_instance.frontend.network_interface[0].network_ip
}

output "backend_private_ip" {
  value = google_compute_instance.backend.network_interface[0].network_ip
}

output "nat_external_ip" {
  value = google_compute_address.nat.address
}

output "website_url" {
  value = "http://${google_compute_address.frontend.address}"
}

output "frontend_ssh_command" {
  value = "ssh -i YOUR_PRIVATE_KEY ${var.ssh_user}@${google_compute_address.frontend.address}"
}

output "backend_ssh_command" {
  value = "ssh -i YOUR_PRIVATE_KEY -J ${var.ssh_user}@${google_compute_address.frontend.address} ${var.ssh_user}@${google_compute_instance.backend.network_interface[0].network_ip}"
}
