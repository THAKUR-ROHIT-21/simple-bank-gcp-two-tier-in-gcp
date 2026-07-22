# Simple Bank — GCP Two-Tier Project

This project contains a complete demo banking registration application, GCP infrastructure in Terraform, Docker deployment, and GitHub Actions CI/CD.

## Application behavior

1. User enters an email address.
2. If the user already exists, the account dashboard is displayed.
3. If the user does not exist, the registration form is displayed.
4. After registration, the new account dashboard is displayed.

This is a learning project, not a real banking system.

## Architecture

```text
Internet
   |
   | HTTP :80
   v
Frontend VM — Public subnet
Docker + Nginx + HTML/CSS/JavaScript
   |
   | Private VPC traffic :5000
   v
Backend VM — Private subnet, no public IP
Docker + Flask API
   |
   | Cloud NAT
   v
MongoDB Atlas
```

The frontend VM also acts as a bastion host for GitHub Actions when deploying to the private backend VM.

## Folder structure

```text
app/backend/                 Flask API and Docker files
app/frontend/                HTML, CSS, JavaScript and Nginx
terraform/                   VPC, subnets, firewall, NAT and VMs
.github/workflows/           application deployment and Terraform validation
scripts/                     helper scripts
```

## 1. Create a new SSH key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/simple-bank-gcp -C "simple-bank-gcp" -N ""
```

Do not print or share the private key.

## 2. Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Update `project_id`, `ssh_user`, and `ssh_public_key_path`.

The example uses your current project ID:

```text
project-03803aec-3f89-45cb-896
```

## 3. Create the GCP infrastructure

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Get the outputs:

```bash
terraform output
```

The backend VM has no public IP. Cloud NAT provides outbound internet access, which is needed for Docker packages and MongoDB Atlas.

## 4. Configure MongoDB Atlas

Get the static NAT IP:

```bash
terraform output -raw nat_external_ip
```

Add it in MongoDB Atlas Network Access as:

```text
NAT_IP/32
```

Create or use database:

```text
simple_bank
```

Do not put the MongoDB URI in the source code.

## 5. Configure GitHub repository secrets

Open:

```text
Repository → Settings → Secrets and variables → Actions
```

Create:

```text
FRONTEND_HOST          Terraform frontend_external_ip output
BACKEND_PRIVATE_IP     Terraform backend_private_ip output
SSH_USER               rohit
GCP_SSH_KEY_B64        Base64-encoded private SSH key
MONGO_URI               MongoDB Atlas connection string
MONGO_DB_NAME           simple_bank
```

Copy the SSH key directly to the Windows clipboard from WSL:

```bash
base64 -w 0 ~/.ssh/simple-bank-gcp | clip.exe
```

Paste it into `GCP_SSH_KEY_B64`. Do not run the command without `| clip.exe` and do not paste the value into chat.

## 6. Push to GitHub

```bash
git init
git add .
git commit -m "Initial simple bank project"
git branch -M main
git remote add origin YOUR_REPOSITORY_URL
git push -u origin main
```

Changes under `app/**` automatically trigger `.github/workflows/deploy-app.yml`.

## 7. Open the application

```bash
terraform output -raw website_url
```

Health check:

```bash
curl http://FRONTEND_IP/api/health
```

## Useful SSH commands

Frontend:

```bash
ssh -i ~/.ssh/simple-bank-gcp rohit@FRONTEND_IP
```

Backend through frontend:

```bash
ssh -i ~/.ssh/simple-bank-gcp -J rohit@FRONTEND_IP rohit@10.20.2.10
```

## Docker troubleshooting

Frontend:

```bash
cd /opt/simple-bank/frontend
docker compose ps
docker compose logs -f
```

Backend:

```bash
cd /opt/simple-bank/backend
docker compose ps
docker compose logs -f
```

## Security note

`allowed_ssh_cidrs = ["0.0.0.0/0"]` is included so GitHub-hosted runners can connect during this demo. For production, use Google Cloud IAP or a self-hosted runner with a fixed IP.

## Destroy

```bash
cd terraform
terraform destroy
```
