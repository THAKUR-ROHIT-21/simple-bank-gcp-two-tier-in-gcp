#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
  ca-certificates \
  curl \
  docker.io \
  docker-compose-v2

systemctl enable --now docker

mkdir -p /opt/simple-bank/backend
chown -R ${ssh_user}:${ssh_user} /opt/simple-bank

usermod -aG docker ${ssh_user}

cat > /etc/motd <<'EOF'
==================================================
 Simple Bank Development Backend VM
 Docker application directory:
 /opt/simple-bank/backend

 This VM has no external public IP.
 Access it through the frontend VM.
==================================================
EOF
