#!/usr/bin/env bash

# Function to prompt the user to select local or SSH mode
prompt_mode() {
    read -p "Do you want to run the script locally or connect via SSH? (local/ssh): " mode
    case "$mode" in
        local|LOCAL|l|L)
            run_locally
            ;;
        ssh|SSH|s|S)
            copy_and_execute_remote
            ;;
        *)
            echo "Invalid choice. Please select a valid mode."
            prompt_mode
            ;;
    esac
}

# Function to copy and execute the script on another device via SSH
copy_and_execute_remote() {
    read -p "Enter the remote username@hostname to copy the script: " remote
    echo "Copying script to $remote:/tmp..."
    scp local_script.sh "$remote:/tmp"
    echo "Executing script on $remote..."
    ssh "$remote" "sudo -S bash /tmp/local_script.sh"
}

# Function to run the script locally
run_locally() {
    echo "Running script locally..."
    chmod +x local_script.sh
    sudo ./local_script.sh
}

# Main script execution
main() {
    prompt_mode
}

main
