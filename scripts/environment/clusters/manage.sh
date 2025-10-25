#!/bin/bash

CLUSTER_NAME="cluster*"

# Function to display the menu
function show_menu() {
    echo "KIND Cluster Management"
    echo "------------------------"
    echo "1. Start KIND Cluster"
    echo "2. Stop KIND Cluster"
    echo "3. Pause KIND Cluster"
    echo "4. Resume KIND Cluster"
    echo "5. Exit"
    echo
    read -p "Choose an option: " choice
}

# Functions to manage the KIND cluster
function start_cluster() {
    echo "Starting KIND cluster..."
    docker ps -a --filter "name=${CLUSTER_NAME}" --format "{{.ID}}" | xargs docker start
    echo "KIND cluster started."
}

function stop_cluster() {
    echo "Stopping KIND cluster..."
    docker ps --filter "name=${CLUSTER_NAME}" --format "{{.ID}}" | xargs docker stop
    echo "KIND cluster stopped."
}

function pause_cluster() {
    echo "Pausing KIND cluster..."
    docker ps --filter "name=${CLUSTER_NAME}" --format "{{.ID}}" | xargs docker pause
    echo "KIND cluster paused."
}

function resume_cluster() {
    echo "Resuming KIND cluster..."
    docker ps -a --filter "name=${CLUSTER_NAME}" --format "{{.ID}}" | xargs docker unpause
    echo "KIND cluster resumed."
}

# Main menu loop
while true; do
    show_menu
    case $choice in
        1)
            start_cluster
            ;;
        2)
            stop_cluster
            ;;
        3)
            pause_cluster
            ;;
        4)
            resume_cluster
            ;;
        5)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo
done