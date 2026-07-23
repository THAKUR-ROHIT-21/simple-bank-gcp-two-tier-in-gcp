#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  apt-transport-https \
  docker.io \
  docker-compose-v2

systemctl enable --now docker

# Install Caddy from the official repository.
install -m 0755 -d /etc/apt/keyrings

curl -1sLf \
  "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" \
  | gpg --dearmor \
  -o /etc/apt/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf \
  "https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt" \
  > /etc/apt/sources.list.d/caddy-stable.list

chmod o+r /etc/apt/keyrings/caddy-stable-archive-keyring.gpg
chmod o+r /etc/apt/sources.list.d/caddy-stable.list

apt-get update
apt-get install -y caddy

systemctl enable caddy

mkdir -p /opt/simple-bank/frontend
chown -R ${ssh_user}:${ssh_user} /opt/simple-bank

usermod -aG docker ${ssh_user}

cat > /etc/caddy/Caddyfile <<'CADDY'
:80 {
    respond /health "dev frontend proxy healthy" 200

    reverse_proxy 127.0.0.1:8080
}
CADDY

caddy validate --config /etc/caddy/Caddyfile
systemctl restart caddy

cat > /etc/motd <<'EOF'
==================================================
 Simple Bank Development Frontend VM
 Docker application directory:
 /opt/simple-bank/frontend
==================================================
EOF
