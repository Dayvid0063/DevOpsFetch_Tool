# DevOpsFetch_Tool

`devopsfetch` is a monitoring tool, it retrieves and displays system information such as active ports, Docker containers, Nginx configurations, and user logins. The tool includes continuous monitoring capabilities through a `systemd` service that logs activities regularly.

## Features

- **Ports**: Display active ports and services; provide details for specific ports.
- **Docker**: List Docker images and containers; provide details for specific containers.
- **Nginx**: Display Nginx domains and ports; provide detailed configuration for specific domains.
- **Users**: List users and their last login times; provide details for specific users.
- **Time Range**: Filter and display activities within a specified time range.
- **help**: Display information about this service

## Installation

### Dependencies

Ensure that the following packages are installed on your system:
- `jq`
- `docker.io`
- `nginx`
- `logrotate`

### Installation Script

To install the necessary dependencies, set up the `devopsfetch` tool, and create systemd services, run the following installation script:

```bash
sudo ./installations.sh
```

### Installation Script Breakdown

1. **Dependencies Installation**: Updates package lists and installs `jq`, `docker.io`, `nginx`, and `logrotate`.
2. **Docker and Nginx Services**: Enables and starts Docker and Nginx services.
3. **Tool Setup**: Copies `devopsfetch.sh` to `/usr/local/bin/` and creates a symbolic link.
4. **Monitoring Script**: Creates a script `system_monitor.sh` to run `devopsfetch` periodically and log the output.
5. **Systemd Service for Monitoring**: Sets up a `systemd` service to run the monitoring script.
6. **Log Rotation**: Configures log rotation for the monitoring logs.
7. **Systemd Service for devopsfetch**: Sets up a `systemd` service to ensure `devopsfetch` runs continuously.

## Usage

### Command-Line Options

- `-p, --port [PORT_NUMBER]`: Display all active ports and services or details for a specific port.
- `-d, --docker [CONTAINER_NAME]`: List Docker images and containers or details for a specific container.
- `-n, --nginx [DOMAIN]`: Display Nginx domains and their ports or details for a specific domain.
- `-u, --users [USERNAME]`: List users and their last login times or details for a specific user.
- `-t, --time [TIME_RANGE]`: Display activities within a specified time range (format: `start_date,end_date`).
- `-h, --help`: Show help message and usage instructions.

### Examples

- List all active ports:
  ```bash
  devopsfetch -p
  ```

- List specific details for a port:
  ```bash
  devopsfetch -p 80
  ```

- List Docker images and containers
  ```bash
  devopsfetch -d
  ```

- Get details for a specific Docker container:
  ```bash
  devopsfetch -d <container_name>
  ```

- Display Nginx domains:
  ```bash
  devopsfetch -n
  ```

- Display Nginx details for a specific domain
  ```bash
  devopsfetch -n localhost
  ```

- List users and their last login times
  ```bash
  devopsfetch -u
  ```

- Get user details:
  ```bash
  devopsfetch -u <username>
  ```

- Filter activities within a time range:
  ```bash
  devopsfetch -t "2024-07-01,2024-07-23"
  ```

- Show help message and usage instructions.
  ```bash
  devopsfetch -h
  ```

## Logging and Monitoring

- **Continuous Monitoring**: The `system-monitor.service` ensures that the `system_monitor.sh` script runs every 12 hours to monitor and log system activities.
- **Log Files**: Logs are saved to `/var/log/system_monitor.log`.

### Log Rotation Configuration

Log rotation is managed by `logrotate` to compress and rotate log files. The configuration files are located in `/etc/logrotate.d/`.
