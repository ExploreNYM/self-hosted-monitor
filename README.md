# self-hosted-monitor
Helpfull scripts to get started self monitoring a vps via prometheus, node-exporter, grafana.


###First Setup VPS used for monitoring

#### 1. Install git
```sh
apt install git

#### 2. clone the repo
```sh
git clone https://github.com/ExploreNYM/self-hosted-monitor ~/self-hosted-monitor
```

#### 3. Setup Prometheus

```sh
chmod +x ~/self-hosted-monitor/prometheus.sh && ~/self-hosted-monitor/prometheus.sh
```

#### 4. Setup Grafana

```sh
chmod +x ~/self-hosted-monitor/grafana.sh && ~/self-hosted-monitor/grafana.sh
```

### You can now access your grafana at http://<youripaddress>:3000 if you prefer to use a domain with https follow step 5.

#### 5. Setup Nginx+Certbot

```sh
chmod +x ~/self-hosted-monitor/nginx-certbot.sh && ~/self-hosted-monitor/nginx-certbot.sh
```


###Now Setup VPS you would like to monitor

#### 1. Install git
```sh
apt install git

#### 2. clone the repo
```sh
git clone https://github.com/ExploreNYM/self-hosted-monitor ~/self-hosted-monitor
```

#### 3. Setup Node-exporter

```sh
chmod +x ~/self-hosted-monitor/node-exporter.sh && ~/self-hosted-monitor/node-exporter.sh
```
