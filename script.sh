#!/bin/bash
MAX_FAILED_ATTEMPTS=5
DEFAULT_SSH_LOG_FILE="/var/log/auth.log"

stop_ssh_service() {
    echo "Stopping SSH service..."
    systemctl stop ssh
}


# Function Debian-based systems
install_mailutils_debian() {
    sudo apt-get install mailutils -y
}

# Function Red Hat-based systems
install_mailutils_redhat() {
    sudo yum install mailx -y
}

# Function Arch-based systems
install_mailutils_arch() {
    sudo pacman -Sy --noconfirm mailutils
}

# Function to prompt the user to install mailutils
prompt_install_mailutils() {
    read -p "Mailutils package is required for sending emails. Do you want to install it now? (yes/no): " choice
    case "$choice" in
        yes|YES|y|Y)
            install_mailutils
            ;;
        *)
            echo "Mailutils is required for sending emails. Exiting..."
            exit 1
            ;;
    esac
}

# Function to install mailutils based on the distribution
install_mailutils() {
    # Check if the system is Debian-based
    if [ -f /etc/debian_version ]; then
        install_mailutils_debian
    # Check if the system is Red Hat-based
    elif [ -f /etc/redhat-release ]; then
        install_mailutils_redhat
    # Check if the system is Arch-based
    elif [ -f /etc/arch-release ]; then
        install_mailutils_arch
    else
        echo "Unsupported distribution. Please install mailutils manually."
        exit 1
    fi
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "You'll need to run this script as root using sudo"
    exit 1
fi

# Check if mailutils is installed
if ! command -v mail &>/dev/null; then
    prompt_install_mailutils
fi

read -p "Use default SSH log file ($DEFAULT_SSH_LOG_FILE)? (yes/no): " use_default
case "$use_default" in
    yes|YES|y|Y)
        logfile="$DEFAULT_SSH_LOG_FILE"
        ;;
    *)
        read -p "Enter location of SSH log file: " logfile
        ;;
esac

# Check if the log file exists
while [ ! -f "$logfile" ]; do
    echo "Error: File not found!"
    read -p "Do you want to input another file location? (yes/no): " choice
    case "$choice" in
        yes|YES|y|Y)
            read -p "Please enter the location of the SSH log file: " logfile
            ;;
        *)
            echo "Exiting..."
            exit 1
            ;;
    esac
done
read -p "Select an option:
1) Read commands sent from IP address
2) Read failed logins on server
3) Read successful logins on server
4) List all SSH connections
5) List all SSH disconnections
6) List all sudo commands executed
Enter your choice: " choice

case $choice in
    1)
        # Read commands sent from IP address
        awk '/session opened/{ip=$11} /command/{print ip, $0}' "$logfile" | awk '!seen[$0]++'
        ;;
    2)
        # Read failed logins on server
        echo 'Failed logins: '
        awk '($6 == "Failed") && ($7 == "password") { print $0 }' "$logfile"
        ;;
    3)
        # Read successful logins on server
        echo 'Successful logins: '
        awk '($6 == "Accepted") { print $0 }' "$logfile"
        ;;
    4)
        # List all SSH connections
        echo 'SSH connections: '
        awk '($6 == "Accepted") { print "IP:", $11, "Date:", $1, $2, "Time:", $3 }' "$logfile"
        ;;
    5)
        # List all SSH disconnections
        echo 'SSH disconnections: '
        awk '($6 == "Disconnected") { print "IP:", $11, "Date:", $1, $2, "Time:", $3 }' "$logfile"
        ;;
    6)
        # List all sudo commands executed
        echo 'Sudo commands executed: '
        cat /root/.bash_history
        ;;
    *)
        echo "Wrong input"
        ;;
esac

