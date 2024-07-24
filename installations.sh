#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Update package list and install dependencies
apt-get update
apt-get install -y jq docker.io nginx logrotate

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Make devopsfetch a command
cp /home/orjidavid/DevOpsFetch_Tool/src/devopsfetch.sh /usr/local/bin/devopsfetch.sh
chmod +x /usr/local/bin/devopsfetch.sh

# Check if the symbolic link exists and remove it if necessary
if [ -L /usr/local/bin/devopsfetch ]; then
    rm /usr/local/bin/devopsfetch
fi

ln -s /usr/local/bin/devopsfetch.sh /usr/local/bin/devopsfetch

# Create the monitoring script
cat << EOF > /home/orjidavid/DevOpsFetch_Tool/src/system_monitor.sh
#!/bin/bash

while true; do
    # Run monitoring
    {
        devopsfetch -p
        echo -e "\n"
        devopsfetch -d
        echo -e "\n"
        devopsfetch -n
        echo -e "\n"
        devopsfetch -u
        echo -e "\n"
        devopsfetch -t
        echo -e "\n"
    } | tee -a /var/log/system_monitor.log

    # Sleep
    sleep 43200
done
EOF

chmod +x /home/orjidavid/DevOpsFetch_Tool/src/system_monitor.sh

# Create systemd service
cat << EOF > /etc/systemd/system/system-monitor.service
[Unit]
Description=System Monitoring Service
After=network.target

[Service]
ExecStart=/home/orjidavid/DevOpsFetch_Tool/src/system_monitor.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable system-monitor.service
systemctl start system-monitor.service

# Set up log rotation
cat << EOF > /etc/logrotate.d/system-monitor
/var/log/system_monitor.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Set up systemd service for devopsfetch
cat << EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
ExecStart=/home/orjidavid/DevOpsFetch_Tool/src/devopsfetch.sh
Restart=always
User=root
RestartSec=10
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

# Apply logrotate configuration
LOGROTATE_CONF="/etc/logrotate.d/devopsfetch"
cat << EOL > $LOGROTATE_CONF
/var/log/devopsfetch.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0644 root root
    su root root
}
EOL

logrotate -f /etc/logrotate.d/devopsfetch
