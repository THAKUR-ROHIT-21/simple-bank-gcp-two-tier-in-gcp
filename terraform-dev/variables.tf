variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "lucky-lead-500506-d2"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-south1-a"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "simple-bank-dev-vpc"
}

variable "public_subnet_name" {
  description = "Public subnet name"
  type        = string
  default     = "simple-bank-dev-public-subnet"
}

variable "private_subnet_name" {
  description = "Private subnet name"
  type        = string
  default     = "simple-bank-dev-private-subnet"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.30.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.30.2.0/24"
}

variable "frontend_private_ip" {
  description = "Frontend VM internal IP"
  type        = string
  default     = "10.30.1.10"
}

variable "backend_private_ip" {
  description = "Backend VM internal IP"
  type        = string
  default     = "10.30.2.10"
}

variable "frontend_machine_type" {
  description = "Frontend VM machine type"
  type        = string
  default     = "e2-micro"
}

variable "backend_machine_type" {
  description = "Backend VM machine type"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_size_gb" {
  description = "VM boot disk size"
  type        = number
  default     = 20
}

variable "ssh_user" {
  description = "Linux SSH username"
  type        = string
  default     = "rohit"
}

variable "ssh_public_key_path" {
  description = "Local SSH public key path"
  type        = string
  default     = "~/.ssh/simple-bank-dev.pub"
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH into frontend VM"
  type        = string
  default     = "0.0.0.0/0"
}

variable "dev_domain" {
  description = "DEV application domain"
  type        = string
  default     = "dev.simplebankgcp.biharibabu.info"
}

variable "labels" {
  description = "Common resource labels"
  type        = map(string)

  default = {
    application = "simple-bank"
    environment = "dev"
    managed-by  = "terraform"
  }
}
