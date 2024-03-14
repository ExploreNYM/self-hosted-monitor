#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo or log in as the root user."
    exit 1
fi

# Installing necessary dependencies
echo "Checking and installing necessary dependencies..."
apt-get update
apt-get install -y software-properties-common wget gnupg

# Add Grafana's GPG key
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -

# Add the Grafana repository
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list

# Update APT sources and install Grafana
echo "Installing Grafana..."
apt-get update
apt-get install -y grafana

# Enable and start the Grafana service
systemctl enable grafana-server
systemctl start grafana-server

echo "Grafana installation and configuration complete."
