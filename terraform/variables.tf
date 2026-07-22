variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "zone" {
  type    = string
  default = "asia-south1-a"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "ssh_user" {
  type    = string
  default = "rohit"
}

variable "ssh_public_key_path" {
  type = string
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "frontend_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "backend_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "frontend_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "backend_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "frontend_private_ip" {
  type    = string
  default = "10.20.1.10"
}

variable "backend_private_ip" {
  type    = string
  default = "10.20.2.10"
}
