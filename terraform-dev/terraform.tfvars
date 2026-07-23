project_id = "lucky-lead-500506-d2"

region = "asia-south1"
zone   = "asia-south1-a"

environment = "dev"

network_name        = "simple-bank-dev-vpc"
public_subnet_name  = "simple-bank-dev-public-subnet"
private_subnet_name = "simple-bank-dev-private-subnet"

public_subnet_cidr  = "10.30.1.0/24"
private_subnet_cidr = "10.30.2.0/24"

frontend_private_ip = "10.30.1.10"
backend_private_ip  = "10.30.2.10"

frontend_machine_type = "e2-micro"
backend_machine_type  = "e2-micro"

boot_disk_size_gb = 20

ssh_user            = "rohit"
ssh_public_key_path = "~/.ssh/simple-bank-dev.pub"

# शुरुआत में testing के लिए:
admin_cidr = "0.0.0.0/0"

dev_domain = "dev.simplebankgcp.biharibabu.info"

labels = {
  application = "simple-bank"
  environment = "dev"
  managed-by  = "terraform"
}
