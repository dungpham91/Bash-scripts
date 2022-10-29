#!/bin/bash
#
# Author: Dung Pham
# Website: https://devopslite.com
# Date: 14/07/2022
# Use: bash install.sh
# Note: run script by user root or sudo

# Update OS and install dependencies
apt update
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install docker and docker compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Reference: https://github.com/8gears/containerized-guacamole
# Create home folder for guacamole
mkdir -p /opt/guacamole
cd /opt/guacamole

# Create file .env with some defined variables
cat > .env <<"EOF"
POSTGRES_USER=postgreuser
POSTGRES_PASSWORD=postgrepass
# Uncomment if you want to test with dummy certificates
# LETSENCRYPT_TEST=false 
VIRTUAL_HOST=guacamole.abc.com
LETSENCRYPT_HOST=guacamole.abc.com
LETSENCRYPT_EMAIL=admin@abc.com
EOF

# Create file docker-compose.yml
cat > docker-compose.yml <<"EOF"
#
# Apache Guacamole with NGIXN reverse proxy and Let's Encrypt.
# For more details see: https://github.com/8gears/containerized-guacamole
# 
version: '3'

services:
  nginx:
    image: jwilder/nginx-proxy:alpine
    labels:
        com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - conf:/etc/nginx/conf.d
      - vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - certs:/etc/nginx/certs:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro

  nginx-letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: nginx-letsencrypt
    restart: unless-stopped
    depends_on:
      - nginx
    volumes:
      - conf:/etc/nginx/conf.d
      - vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - certs:/etc/nginx/certs:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro

  init-guac-db:
    image: guacamole/guacamole:latest
    command: ["/bin/sh", "-c", "test -e /init/initdb.sql && echo 'init file already exists' || /opt/guacamole/bin/initdb.sh --postgres > /init/initdb.sql" ]
    volumes:
      - dbinit:/init    

  postgres:
    image: postgres:13
    restart: unless-stopped
    volumes:
      - dbinit:/docker-entrypoint-initdb.d        
      - dbdata:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-guacadb} 
      POSTGRES_PASSWORD: 
    depends_on:
      - init-guac-db

  guacd:
    image: guacamole/guacd:latest
    restart: unless-stopped

  guac:
    image: guacamole/guacamole:latest
    restart: unless-stopped
    environment:
      TOTP_ENABLED: 'true'
      GUACD_HOSTNAME: guacd
      POSTGRES_HOSTNAME: postgres
      POSTGRES_DATABASE: ${POSTGRES_USER:-guacadb} 
      POSTGRES_USER: ${POSTGRES_USER:-guacadb} 
      POSTGRES_PASSWORD:
      LETSENCRYPT_TEST: ${LETSENCRYPT_TEST:-false}
      VIRTUAL_HOST: 
      LETSENCRYPT_HOST: ${VIRTUAL_HOST}
      LETSENCRYPT_EMAIL: 
    depends_on:
      - postgres
      - guacd

volumes:
  dbinit:
  dbdata:
  conf:
  vhost:
  html:
  certs:
EOF

# Run docker compose
docker-compose up init-guac-db
docker-compose up -d

## Login to: https://guacamole.abc.com/guacamole with "guacadmin/guacadmin"
## After login sucessfully, change the admin account as you want