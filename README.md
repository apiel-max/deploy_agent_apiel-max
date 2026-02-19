**This is my link to run through the video where i have clearly explained how my project works**  https://drive.google.com/file/d/184Chx2k3mHWWXO-sDMXqy8PBp8T0XIKZ/view?usp=sharing
# Attendance Tracker Project

## Overview
An automated attendance tracking system that monitors student attendance and generates alerts for students falling below warning or failure thresholds.

## Features
- Automated attendance percentage calculation
- Configurable warning and failure thresholds
- Alert generation for at-risk students
- Report archiving with timestamps
- Live and dry-run modes

## Project Structure
```
attendance_tracker_<name>/
├── attendance_checker.py    # Main script
├── Helpers/
│   ├── assets.csv           # Student attendance data
│   └── config.json          # Configuration settings
└── reports/
    └── reports.log          # Generated alerts
```

## Setup

### Prerequisites
- Python 3.x
- Bash shell (Linux/macOS/Git Bash on Windows)

### Installation
Run the setup script:
```bash
bash setup_project.sh
```

Follow the prompts to:
1. Enter a project name
2. Optionally customize attendance thresholds

## Configuration

### config.json
```json
{
    "thresholds": {
        "warning": 75,    // Warning threshold percentage
        "failure": 50     // Failure threshold percentage
    },
    "run_mode": "live",   // "live" or "dry-run"
    "total_sessions": 15  // Total class sessions
}
```

### assets.csv
CSV file containing student data:
- Email: Student email address
- Names: Student name
- Attendance Count: Number of sessions attended
- Absence Count: Number of sessions missed

## Usage

Navigate to the project directory and run:
```bash
cd attendance_tracker_<name>
python3 attendance_checker.py
```

### Run Modes
- **Live mode**: Writes alerts to `reports/reports.log`
- **Dry-run mode**: Displays alerts in console only

## Output
Alerts are generated based on attendance percentage:
- **Below failure threshold**: URGENT message
- **Below warning threshold**: WARNING message
- **Above warning threshold**: No alert

Previous reports are automatically archived with timestamps.

## Interrupt Handling
If setup is interrupted (Ctrl+C), the script will:
1. Archive the incomplete project
2. Clean up temporary files
3. Exit gracefully

## Author
Created for attendance monitoring and student alert system.
