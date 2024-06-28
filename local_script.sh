#!/bin/bash

MAX_FAILED_ATTEMPTS=5
DEFAULT_SSH_LOG_FILE="/var/log/auth.log"

# Ensure the script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root using sudo."
        exit 1
    fi
}


# Prompt for log file location
prompt_logfile() {
    echo "Use default SSH log file ($DEFAULT_SSH_LOG_FILE)? (yes/no): "
    read -p "" use_default
    case "$use_default" in
        yes|YES|y|Y)
            logfile="$DEFAULT_SSH_LOG_FILE"
            ;;
        *)
            read -p "Enter location of SSH log file: " logfile
            ;;
    esac

    # Validate the log file
    if [ ! -f "$logfile" ]; then
        echo "Error: File not found!"
        prompt_logfile
    fi
}

# Display menu options
display_menu() {
    echo "Select an option:"
    echo "1) Read commands sent from IP address"
    echo "2) Read failed logins on server"
    echo "3) Read successful logins on server"
    echo "4) List all SSH connections"
    echo "5) List all SSH disconnections"
    echo "6) List all sudo commands executed"
    echo "7) Display the last logins to the system with IP addresses"
}

# Execute selected option
execute_choice() {
    read -p "Enter your choice: " choice
    case $choice in
        1)
            echo 'Commands sent from IP addresses: '
            awk '/session opened/{ip=$11} /command/{print ip, $0}' "$logfile" | awk '!seen[$0]++'
            ;;
        2)
            echo 'Failed logins: '
            awk '($6 == "Failed") && ($7 == "password") { print $0 }' "$logfile"
            ;;
        3)
            echo 'Successful logins: '
            awk '($6 == "Accepted") { print $0 }' "$logfile"
            ;;
        4)
            echo 'SSH connections: '
            awk '($6 == "Accepted") { print "IP:", $11, "Date:", $1, $2, "Time:", $3 }' "$logfile"
            ;;
        5)
            echo 'SSH disconnections: '
            awk '($6 == "Disconnected") { print "IP:", $11, "Date:", $1, $2, "Time:", $3 }' "$logfile"
            ;;
        6)
            echo 'Sudo commands executed: '
            cat /root/.bash_history
            ;;
        7)
            echo 'Last logins with IP addresses: '
            last -i | awk '!seen[$1, $3, $4]++'
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            display_menu
            execute_choice
            ;;
    esac
}

# Main script execution
main() {
    check_root
    prompt_logfile
    display_menu
    execute_choice
}

main
