#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform"
echo "FRONTEND_HOST=$(terraform output -raw frontend_external_ip)"
echo "BACKEND_PRIVATE_IP=$(terraform output -raw backend_private_ip)"
echo "NAT_IP_FOR_ATLAS=$(terraform output -raw nat_external_ip)/32"
echo "SSH_USER=rohit"
echo "MONGO_DB_NAME=simple_bank"
