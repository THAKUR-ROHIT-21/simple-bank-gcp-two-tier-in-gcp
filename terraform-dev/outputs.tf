output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "Deployment region"
  value       = var.region
}

output "vpc_name" {
  description = "Development VPC name"
  value       = google_compute_network.dev_vpc.name
}

output "frontend_external_ip" {
  description = "Frontend static public IP"
  value       = google_compute_address.frontend_public_ip.address
}

output "frontend_private_ip" {
  description = "Frontend internal IP"
  value       = google_compute_instance.frontend.network_interface[0].network_ip
}

output "backend_private_ip" {
  description = "Backend internal IP"
  value       = google_compute_instance.backend.network_interface[0].network_ip
}

output "nat_public_ip" {
  description = "Cloud NAT public IP; whitelist this in MongoDB Atlas"
  value       = google_compute_address.nat_ip.address
}

output "frontend_ssh_command" {
  description = "SSH command for frontend VM"

  value = join(" ", [
    "ssh",
    "-i",
    trimsuffix(var.ssh_public_key_path, ".pub"),
    "${var.ssh_user}@${google_compute_address.frontend_public_ip.address}"
  ])
}

output "backend_ssh_command" {
  description = "SSH command for backend through frontend VM"

  value = join(" ", [
    "ssh",
    "-i",
    trimsuffix(var.ssh_public_key_path, ".pub"),
    "-o",
    "\"ProxyCommand=ssh -i ${trimsuffix(var.ssh_public_key_path, ".pub")} -W %h:%p ${var.ssh_user}@${google_compute_address.frontend_public_ip.address}\"",
    "${var.ssh_user}@${google_compute_instance.backend.network_interface[0].network_ip}"
  ])
}

output "dev_domain" {
  description = "Development domain"
  value       = var.dev_domain
}

output "dns_a_record_value" {
  description = "Create a DNS A record pointing to this IP"
  value       = google_compute_address.frontend_public_ip.address
}

output "mongodb_atlas_whitelist_cidr" {
  description = "Add this NAT IP to MongoDB Atlas Network Access"
  value       = "${google_compute_address.nat_ip.address}/32"
}
