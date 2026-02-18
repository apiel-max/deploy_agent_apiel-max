#!/bin/bash

# Store project name and directory path
PROJECT_NAME=""
PROJECT_DIR=""

# Handle interruption by archiving incomplete project
cleanup_on_interrupt() {
    echo ""
    echo "Setup interrupted! Archiving current state..."
    
    # Check if project directory exists before archiving
    if [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_NAME}_archive.tar.gz"
        # Create compressed archive of incomplete project
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null
        echo "Archive created: $ARCHIVE_NAME"
        
        # Remove incomplete directory to clean up
        rm -rf "$PROJECT_DIR"
        echo "Incomplete directory removed"
    fi
    
    echo "Exiting..."
    exit 1
}

# Enable interrupt handling with trap
trap cleanup_on_interrupt SIGINT

echo "=== Attendance Tracker Project Setup ==="
echo ""

# Prompt user for project name with directory existence check
while true; do
    read -p "Enter Project Name: " USER_INPUT
    PROJECT_NAME="attendance_tracker_${USER_INPUT}"
    PROJECT_DIR="$PROJECT_NAME"
    
    if [ -d "$PROJECT_DIR" ]; then
        echo "Error: Directory '$PROJECT_DIR' already exists. Please enter a different name."
        echo ""
    else
        break
    fi
done

echo ""
echo "Creating project: $PROJECT_NAME"

mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

cat > "$PROJECT_DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log',
                  f'reports/reports_{timestamp}.log.archive')
    
    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, \
         open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat > "$PROJECT_DIR/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > "$PROJECT_DIR/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

touch "$PROJECT_DIR/reports/reports.log"

echo "The directory structure has successfully been created."
echo ""

# Ask user if they want to update attendance thresholds
read -p "Do you want to update attendance thresholds? (y/n): " UPDATE_THRESHOLDS

if [ "$UPDATE_THRESHOLDS" = "y" ] || [ "$UPDATE_THRESHOLDS" = "Y" ]; then
    read -p "Enter Warning threshold (default 75): " WARNING_THRESHOLD
    read -p "Enter Failure threshold (default 50): " FAILURE_THRESHOLD
    
    # Apply default values if user leaves input empty
    WARNING_THRESHOLD=${WARNING_THRESHOLD:-75}
    FAILURE_THRESHOLD=${FAILURE_THRESHOLD:-50}
    
    # Update configuration file with new threshold values
    sed -i "s/\"warning\": [0-9]*/\"warning\": $WARNING_THRESHOLD/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $FAILURE_THRESHOLD/" "$PROJECT_DIR/Helpers/config.json"
    
    echo "Thresholds updated: Warning=$WARNING_THRESHOLD%, Failure=$FAILURE_THRESHOLD%"
fi

echo ""
echo "=== Environment Validation ==="
echo ""
echo "Running health check..."


# Verify Python 3 is installed on the system
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "$PYTHON_VERSION is installed"
else
    echo "WARNING: python3 is not installed on this system"
fi

# Confirm all required files and directories were created
if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -d "$PROJECT_DIR/reports" ]; then
    echo "Directory structure verified"
else
    echo "WARNING: Directory structure is incomplete"
fi

echo ""
echo "=== Setup Complete ==="
echo "Project created at: $PROJECT_DIR"
echo "To run: cd $PROJECT_DIR && python3 attendance_checker.py"
