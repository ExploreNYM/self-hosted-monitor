#!/bin/bash

# Ask for target IP address with a default value
read -p "Enter target IP address (102.117.125.12): " target_ip
target_ip=${target_ip:-102.117.125.12}

# Ask for target port with a default value of 9100
read -p "Enter target port (node-exporter default 9100): " target_port
target_port=${target_port:-9100}

# Set job name
job_name='nym-monitor'

# File path
config_file="/etc/prometheus/prometheus.yml"
temp_file="/tmp/prometheus.yml"

# Check if the job_name exists in the prometheus.yml file
if grep -q "job_name: '$job_name'" $config_file; then
  echo "Job $job_name already exists. Adding target $target_ip:$target_port."

  # Use awk to properly add the target to the existing job's static_configs
  awk -v job="$job_name" -v target="$target_ip:$target_port" -v OFS='\n' '
    /job_name: .*/ && !found {
      found = ($2 == "\"" job "\"")
    }
    found && /static_configs:/ {
      print
      getline
      print "      - targets: ['" target "']"
      found = 0
    }
    { print }
  ' $config_file > $temp_file && mv $temp_file $config_file
else
  echo "Job $job_name does not exist. Adding job and target $target_ip:$target_port."
  
  # Append the new job configuration to the prometheus.yml file
  cat >> $config_file <<EOF

  - job_name: '$job_name'
    static_configs:
      - targets: ['$target_ip:$target_port']
EOF
fi

# Restart Prometheus to apply changes
systemctl restart prometheus

echo "Prometheus target added."
