#!/bin/bash

# Check if the script is run as root, exit if not
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" >&2
   exit 1
fi

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to check and create a backup of the Nginx configuration
backup_nginx_configuration() {
    if [ ! -d "/etc/nginx/backup" ]; then
        mkdir -p /etc/nginx/backup
    fi
    cp /etc/nginx/nginx.conf /etc/nginx/backup/nginx.conf.$(date +%Y%m%d%H%M)
}

# Prompt the user to enter a domain
read -p "Enter your domain (e.g., explorenym.net): " DOMAIN

# Update and install necessary packages
echo "Updating package lists..."
apt-get update

echo "Checking if Nginx is installed..."
if ! is_package_installed nginx; then
    echo "Nginx is not installed. Installing Nginx..."
    apt-get install -y nginx
else
    echo "Nginx is already installed."
fi

# Backup the current Nginx configuration
echo "Backing up the current Nginx configuration..."
backup_nginx_configuration

# Create an Nginx server block file
echo "Configuring Nginx for $DOMAIN..."
cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    # SSL configuration
    listen 443 ssl http2;
    server_name $DOMAIN;

    # Specify dummy SSL certificates (Certbot will replace these later)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable the Nginx site by creating a symlink
if [ ! -e /etc/nginx/sites-enabled/$DOMAIN ]; then
    ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    echo "Enabled the Nginx configuration for $DOMAIN."
else
    echo "The symlink for $DOMAIN already exists."
fi

# Validate the Nginx configuration
echo "Validating Nginx configuration..."
nginx -t

# Reload Nginx to apply the changes
echo "Reloading Nginx..."
nginx -s reload

# Install Certbot if it's not already installed
echo "Ensuring Certbot is installed..."
if ! is_package_installed snapd; then
    echo "snapd is not installed. Installing snapd..."
    apt install snapd -y
fi

if ! snap list | grep -q certbot; then
    echo "Certbot is not installed. Installing Certbot..."
    snap install core; snap refresh core
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
else
    echo "Certbot is already installed."
fi

echo "Obtaining SSL certificates and configuring Nginx..."
# Run Certbot without an email and agreeing to the terms of service
certbot --nginx --register-unsafely-without-email -d $DOMAIN --redirect

# Validate the Nginx configuration after Certbot changes
echo "Validating Nginx configuration post-Certbot..."
nginx -t

# Restart Nginx to apply SSL configurations
echo "Restarting Nginx..."
systemctl restart nginx

echo "Script completed successfully."
