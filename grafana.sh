#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo or log in as the root user."
    exit 1
fi

# Installing necessary dependencies
echo "Checking and installing necessary dependencies..."
if ! command -v wget &> /dev/null; then
    echo "wget could not be found, installing..."
    apt-get update && apt-get install wget -y
fi

# Set Grafana version
grafana_version="9.1.0"

# Create a user for Grafana without a home directory
useradd --no-create-home --shell /bin/false grafana

# Create necessary directories
mkdir /var/lib/grafana
mkdir /etc/grafana
mkdir /var/log/grafana

# Set ownership
chown grafana:grafana /var/lib/grafana
chown grafana:grafana /var/log/grafana
chown grafana:grafana /etc/grafana

# Download Grafana
echo "Downloading Grafana version $grafana_version..."
wget "https://dl.grafana.com/oss/release/grafana-${grafana_version}.linux-amd64.tar.gz" -O /tmp/grafana-$grafana_version.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Failed to download Grafana."
    exit 1
fi

# Unarchive Grafana
echo "Unarchiving Grafana..."
tar xvfz /tmp/grafana-$grafana_version.linux-amd64.tar.gz -C /tmp
if [ $? -ne 0 ]; then
    echo "Failed to unarchive Grafana."
    exit 1
fi

# Move Grafana binaries and other files
echo "Setting up Grafana..."
cp -r /tmp/grafana-$grafana_version/bin/* /usr/local/bin/
cp -r /tmp/grafana-$grafana_version/public /usr/share/grafana
cp -r /tmp/grafana-$grafana_version/conf /etc/grafana

# Set ownership
chown -R grafana:grafana /usr/share/grafana
chown -R grafana:grafana /etc/grafana

# Create Grafana service file
echo "Creating Grafana service file..."
cat <<EOF > /etc/systemd/system/grafana-server.service
[Unit]
Description=Grafana
After=network.target

[Service]
User=grafana
Group=grafana
Type=simple
ExecStart=/usr/local/bin/grafana-server \
  --config=/etc/grafana/grafana.ini \
  --homepath /usr/share/grafana

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start Grafana service
echo "Configuring systemd for Grafana..."
systemctl daemon-reload
systemctl enable grafana-server.service
systemctl start grafana-server.service

# Cleanup
echo "Cleaning up..."
rm -rf /tmp/grafana-${grafana_version}*
rm -rf /tmp/grafana-$grafana_version

echo "Grafana installation and configuration complete."
