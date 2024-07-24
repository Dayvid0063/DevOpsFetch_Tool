#!/bin/bash


# Function to display help
function display_help {
  echo "Usage: devopsfetch [options]"
  echo "Options:"
  echo "  -p, --port [PORT_NUMBER] "
  echo "  -d, --docker [CONTAINER_NAME] "
  echo "  -n, --nginx [DOMAIN] "
  echo "  -u, --users [USERNAME] "
  echo "  -t, --time [TIME_RANGE] "
  echo "  -h, --help "
}

# Function to list ports
function list_ports {
  if [ -z "$1" ]; then
    echo "Active Ports and Services"
    netstat -tuln | column -t
  else
    echo "Details for Port $1"
    netstat -tuln | grep ":$1 " | column -t
  fi
}

# Function to list Docker images and containers in table format
function list_docker {
  if [ -z "$1" ]; then
    echo "Docker Images"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"
    echo ""
    echo "Docker Containers"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"
  else
    echo "Details for Docker Container $1"
    docker inspect "$1"
  fi
}

# Function to list Nginx domains and their ports
function list_nginx {
  if [ -z "$1" ]; then
    echo "Nginx Domains and Ports"
    grep -r "server_name" /etc/nginx/sites-available/* | column -t
  else
    echo "Details for Nginx Domain $1"
    grep -r "server_name $1" /etc/nginx/sites-available/* | column -t
  fi
}

# Function to list users and their last login times
function list_users {
  if [ -z "$1" ]; then
    echo "Users and Last Login Times"
    lastlog | column -t
  else
    echo "Details for User $1"
    getent passwd "$1" | column -t
    echo ""
    lastlog -u "$1" | column -t
  fi
}

# Function to filter activities within a specified time range
function filter_time_range {
  if [ -z "$1" ]; then
    echo "Please provide a time range."
    exit 1
  fi

  start_date=$(echo $1 | cut -d, -f1)
  end_date=$(echo $1 | cut -d, -f2)

  echo -e "Activities from $start_date to $end_date\n"
  # Adjust the log file path and date format as needed
  awk -v start="$start_date" -v end="$end_date" -F'[ .:]' '
  {
    date = $1 "-" $2 "-" $3
    if (date >= start && date <= end) print $0
  }' /var/log/syslog
}

# main Function
main() {
    if [[ $# -eq 0 ]]; then
        display_help
        exit 1
    fi

    while [[ "$1" != "" ]]; do
        case $1 in
            -h | --help )
                display_help
                exit
                ;;
            -p | --port )
                shift
                list_ports "$1"
                ;;
            -d | --docker )
                shift
                list_docker "$1"
                ;;
            -n | --nginx )
                shift
                list_nginx "$1"
                ;;
            -u | --users )
                shift
                list_users "$1"
                ;;
            -t | --time )
                shift
                filter_time_range "$1"
                ;;
            * )
                display_help
                exit 1
                ;;
        esac
        shift
    done
}

main "$@"
