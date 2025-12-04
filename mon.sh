#!/bin/bash
# script to parse arguments and monitor log files

Code_to_monitor="505"
who_to_inform="adeyinkaoluwatosin123@gmail.com"
LOGFILE="${1:-}"  # Fixed: empty default if no argument

# Function to parse arguments
parse_argument() {
    if [ -z "$LOGFILE" ]; then
        echo "Usage: $0 <logfile>"
        exit 1
    fi
}

# Function to check if file exists
if_file_exists() {
    if [ ! -f "$LOGFILE" ]; then
        echo "Error: File '$LOGFILE' not found!"
        exit 1
    else
        echo "File '$LOGFILE' found. Proceeding with monitoring..."
    fi
}

# Function to monitor log file
monitor_log_file() {
    # Get initial file size
    initial_size=$(stat -c%s "$LOGFILE" 2>/dev/null || echo 0)
    
    echo "Monitoring for HTTP $Code_to_monitor errors..."
    echo "Initial file size: $initial_size bytes"
    echo "----------------------------------------"
    
    # Monitor the log file
    tail -F -c +$((initial_size + 1)) "$LOGFILE" | while read -r LINE; do
        # Extract response code (9th field in Apache logs)
        rc=$(echo "$LINE" | awk '{print $9}')
        # Extract endpoint (7th field in Apache logs)
        endpoint=$(echo "$LINE" | awk '{print $7}')
        
        echo "Response_code: $rc for endpoint: $endpoint"
        
        # Check if response code matches the code to monitor
        if [ "$rc" = "$Code_to_monitor" ]; then
            echo "🚨 ALERT: HTTP $rc detected for endpoint: $endpoint"
            echo "   Full log: $LINE"
            echo "----------------------------------------"
            
            # Here you would add email sending:
             echo "ALERT: HTTP $rc at $(date)" | mail -s "Server Alert" "$who_to_inform"
        fi
    done
}

# Main execution
parse_argument
if_file_exists
monitor_log_file
