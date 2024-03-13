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

if ! command -v tar &> /dev/null; then
    echo "tar could not be found, installing..."
    apt-get install tar -y
fi

# Set Prometheus version
prometheus_version="2.35.0"

# Create a user for Prometheus without a home directory
useradd --no-create-home --shell /bin/false prometheus

# Create necessary directories
mkdir /etc/prometheus
mkdir /var/lib/prometheus

# Set ownership
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus version $prometheus_version..."
wget "https://github.com/prometheus/prometheus/releases/download/v$prometheus_version/prometheus-$prometheus_version.linux-amd64.tar.gz" -O /tmp/prometheus-$prometheus_version.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Failed to download Prometheus."
    exit 1
fi

# Unarchive Prometheus
echo "Unarchiving Prometheus..."
tar xvfz /tmp/prometheus-$prometheus_version.linux-amd64.tar.gz -C /tmp
if [ $? -ne 0 ]; then
    echo "Failed to unarchive Prometheus."
    exit 1
fi

# Move Prometheus binaries
echo "Setting up Prometheus..."
cp /tmp/prometheus-$prometheus_version.linux-amd64/prometheus /usr/local/bin/
cp /tmp/prometheus-$prometheus_version.linux-amd64/promtool /usr/local/bin/

# Set ownership
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Move configuration files and set ownership
cp -r /tmp/prometheus-$prometheus_version.linux-amd64/consoles /etc/prometheus
cp -r /tmp/prometheus-$prometheus_version.linux-amd64/console_libraries /etc/prometheus
cp /tmp/prometheus-$prometheus_version.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /etc/prometheus

# Create Prometheus service file
echo "Creating Prometheus service file..."
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start Prometheus service
echo "Configuring systemd for Prometheus..."
systemctl daemon-reload
systemctl enable prometheus.service
systemctl start prometheus.service

# Cleanup
echo "Cleaning up..."
rm -rf /tmp/prometheus-${prometheus_version}.linux-amd64.tar.gz
rm -rf /tmp/prometheus-${prometheus_version}.linux-amd64

echo "Prometheus installation and configuration complete."
