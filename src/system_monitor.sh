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
