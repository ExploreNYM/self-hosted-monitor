# Self-Hosted Monitor

This repository provides scripts to help you set up a self-hosted monitoring system for your VPS using Prometheus, Node Exporter, and Grafana. This setup enables you to collect and visualize metrics, and create alerts to monitor the health and performance of your servers.

### What are Prometheus, Node Exporter, and Grafana?

- **Prometheus**: An open-source monitoring system with a time series database. It collects and stores metrics as time series data, allowing users to query and alert on this data.
- **Node Exporter**: A Prometheus exporter that collects a choice of hardware and OS metrics exposed by *NIX kernels based on config.
- **Grafana**: An open-source platform for monitoring and observability. It allows you to visualize and alert on your metrics, with support for various data sources, including Prometheus.

<img width="1714" alt="Screenshot 2024-03-16 at 00 23 37" src="https://github.com/ExploreNYM/self-hosted-monitor/assets/60665157/79a0f735-f3ce-4e52-b25c-9c0b7867ba7b">

### Recommended System Requirements for a Basic Monitor

- 2 CPU cores
- 4 GB of memory
- 20 GB of free disk space

## Setting Up the Monitoring Server

### Prerequisites

- Ensure you have root access or sufficient permissions to install packages and make network configurations.
- The instructions are tailored for Debian/Ubuntu systems. Adapt commands accordingly for other distributions.

### 1. Install Git

Git is required to clone the repository containing the necessary scripts.

```sh
apt install git
```

### 2. Clone the Repository

Clone the repository to download the scripts to your server.

```sh
git clone https://github.com/ExploreNYM/self-hosted-monitor ~/self-hosted-monitor
```

### 3. Setup Prometheus

Execute the script to install and configure Prometheus.

```sh
chmod +x ~/self-hosted-monitor/prometheus.sh && ~/self-hosted-monitor/prometheus.sh
```

### 4. Setup Grafana

Run the script to install Grafana, which will be used for visualizing the data collected by Prometheus.

```sh
chmod +x ~/self-hosted-monitor/grafana.sh && ~/self-hosted-monitor/grafana.sh
```

### 5. Decide on Access Method for Grafana

#### Option A: HTTP Access (not recommended since it is unencrypted)

For accessing Grafana via HTTP:

```sh
ufw allow 3000
```

Then, access Grafana at `http://your-ip-address:3000`.

#### Option B: HTTPS Access via Personal Domain

If you prefer HTTPS access using your domain, ensure your domain DNS is pointing to your server's IP and then run the script to set up Nginx and Certbot for SSL:

```sh
chmod +x ~/self-hosted-monitor/nginx-certbot.sh && ~/self-hosted-monitor/nginx-certbot.sh
```

### 6. Add Scrape Target (can be run multiple times)

To monitor a new server, use this script to add it as a target to Prometheus.

```sh
chmod +x ~/self-hosted-monitor/prometheus-target.sh && ~/self-hosted-monitor/prometheus-target.sh
```

## Setting Up the Target Server

These steps should be followed on the server you wish to monitor.

### 1. Install Git

```sh
apt install git
```

### 2. Clone the Repository

```sh
git clone https://github.com/ExploreNYM/self-hosted-monitor ~/self-hosted-monitor
```

### 3. Setup Node Exporter

This script installs Node Exporter, which will collect metrics to be scraped by Prometheus.

```sh
chmod +x ~/self-hosted-monitor/node-exporter.sh && ~/self-hosted-monitor/node-exporter.sh
```

## Verification and Troubleshooting

- After each installation step, verify that the service is running correctly. For example, check if Prometheus and Grafana services are active using `systemctl status prometheus` `systemctl status grafana-server` `systemctl status node-exporter`.
  <img width="241" alt="Screenshot 2024-03-16 at 01 31 53" src="https://github.com/ExploreNYM/self-hosted-monitor/assets/60665157/30c99772-bc48-4272-8d99-102fa8c1380d">
- Access the Grafana UI by navigating to `http://your-ip-address:3000` or `https://your-domain` based on your setup and confirm that the Prometheus data source is connected.
- If you encounter issues, check the respective service logs for detailed error messages (e.g., `journalctl -u prometheus`).


## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Node Exporter GitHub Repository](https://github.com/prometheus/node_exporter)
- [Grafana Documentation](https://grafana.com/docs/)

## Need Help?

If you need help or want to contribute to the project, feel free to open an issue or a pull request in the repository.
