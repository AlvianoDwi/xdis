#!/bin/bash

# Script untuk monitoring auto restart script
BOT_DIR="/workspaces/$(basename $PWD)"
LOG_FILE="$BOT_DIR/bot.log"
MANAGER_LOG="$BOT_DIR/bot_manager.log"
PID_FILE="$BOT_DIR/bot.pid"

# Colors untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function untuk print dengan warna
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function untuk check auto restart script
check_auto_restart_script() {
    echo "=== Checking Auto Restart Script Status ==="
    
    # Check bash script
    bash_process=$(ps aux | grep -v grep | grep "auto_restart.sh")
    if [ ! -z "$bash_process" ]; then
        print_status $GREEN "✓ Bash auto restart script is running"
        echo "Process: $bash_process"
    else
        print_status $RED "✗ Bash auto restart script not found"
    fi
    
    # Check python script
    python_process=$(ps aux | grep -v grep | grep "auto_restart.py")
    if [ ! -z "$python_process" ]; then
        print_status $GREEN "✓ Python auto restart script is running"
        echo "Process: $python_process"
    else
        print_status $RED "✗ Python auto restart script not found"
    fi
    
    echo ""
}

# Function untuk check bot status
check_bot_status() {
    echo "=== Checking Bot Status ==="
    
    # Check PID file
    if [ -f "$PID_FILE" ]; then
        pid=$(cat $PID_FILE)
        if kill -0 $pid 2>/dev/null; then
            print_status $GREEN "✓ Bot is running with PID: $pid"
            
            # Get process info
            process_info=$(ps -p $pid -o pid,ppid,cmd,etime --no-headers)
            echo "Process info: $process_info"
        else
            print_status $RED "✗ PID file exists but process not running (PID: $pid)"
        fi
    else
        print_status $YELLOW "⚠ No PID file found"
    fi
    
    # Check all AnonXMusic processes
    anonx_processes=$(ps aux | grep -v grep | grep "AnonXMusic")
    if [ ! -z "$anonx_processes" ]; then
        print_status $BLUE "AnonXMusic processes found:"
        echo "$anonx_processes"
    else
        print_status $RED "✗ No AnonXMusic processes found"
    fi
    
    echo ""
}

# Function untuk check screen/tmux sessions
check_sessions() {
    echo "=== Checking Screen/Tmux Sessions ==="
    
    # Check screen sessions
    screen_sessions=$(screen -ls 2>/dev/null | grep -E "(botmanager|anonx|keeper)")
    if [ ! -z "$screen_sessions" ]; then
        print_status $GREEN "Screen sessions found:"
        echo "$screen_sessions"
    else
        print_status $YELLOW "No relevant screen sessions found"
    fi
    
    # Check tmux sessions
    tmux_sessions=$(tmux list-sessions 2>/dev/null | grep -E "(botmanager|anonx|keeper)")
    if [ ! -z "$tmux_sessions" ]; then
        print_status $GREEN "Tmux sessions found:"
        echo "$tmux_sessions"
    else
        print_status $YELLOW "No relevant tmux sessions found"
    fi
    
    echo ""
}

# Function untuk check logs
check_logs() {
    echo "=== Checking Recent Logs ==="
    
    # Check bot log
    if [ -f "$LOG_FILE" ]; then
        print_status $GREEN "Bot log file exists: $LOG_FILE"
        echo "Last 5 lines:"
        tail -5 "$LOG_FILE" | while read line; do
            echo "  $line"
        done
        
        # Check for recent activity (last 5 minutes)
        recent_logs=$(find "$LOG_FILE" -mmin -5 2>/dev/null)
        if [ ! -z "$recent_logs" ]; then
            print_status $GREEN "✓ Bot log has recent activity (last 5 minutes)"
        else
            print_status $YELLOW "⚠ No recent activity in bot log"
        fi
    else
        print_status $RED "✗ Bot log file not found"
    fi
    
    # Check manager log
    if [ -f "$MANAGER_LOG" ]; then
        print_status $GREEN "Manager log file exists: $MANAGER_LOG"
        echo "Last 3 lines:"
        tail -3 "$MANAGER_LOG" | while read line; do
            echo "  $line"
        done
    else
        print_status $YELLOW "Manager log file not found"
    fi
    
    echo ""
}

# Function untuk check network connections
check_network() {
    echo "=== Checking Network Connections ==="
    
    # Check for Telegram connections (port 443)
    telegram_connections=$(netstat -tn 2>/dev/null | grep ":443" | grep ESTABLISHED)
    if [ ! -z "$telegram_connections" ]; then
        print_status $GREEN "✓ Telegram connections found (port 443)"
        connection_count=$(echo "$telegram_connections" | wc -l)
        echo "Active connections: $connection_count"
    else
        print_status $YELLOW "⚠ No Telegram connections found"
    fi
    
    echo ""
}

# Function untuk check system resources
check_resources() {
    echo "=== Checking System Resources ==="
    
    # Memory usage
    memory_usage=$(free -h | awk 'NR==2{printf "Memory: %s/%s (%.2f%%)", $3,$2,$3*100/$2 }')
    print_status $BLUE "$memory_usage"
    
    # CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    print_status $BLUE "CPU Usage: ${cpu_usage}%"
    
    # Disk usage
    disk_usage=$(df -h . | awk 'NR==2{printf "Disk: %s/%s (%s)", $3,$2,$5}')
    print_status $BLUE "$disk_usage"
    
    echo ""
}

# Function untuk show uptime info
show_uptime() {
    echo "=== Uptime Information ==="
    
    if [ -f "$PID_FILE" ]; then
        pid=$(cat $PID_FILE)
        if kill -0 $pid 2>/dev/null; then
            # Get process start time
            start_time=$(ps -o lstart= -p $pid 2>/dev/null)
            if [ ! -z "$start_time" ]; then
                print_status $BLUE "Bot started: $start_time"
            fi
            
            # Get elapsed time
            elapsed=$(ps -o etime= -p $pid 2>/dev/null | tr -d ' ')
            if [ ! -z "$elapsed" ]; then
                print_status $BLUE "Bot uptime: $elapsed"
            fi
        fi
    fi
    
    echo ""
}

# Function untuk live monitoring
live_monitor() {
    echo "=== Live Monitoring Mode ==="
    echo "Press Ctrl+C to exit"
    echo ""
    
    while true; do
        clear
        echo "=== AnonXMusic Bot Monitor - $(date) ==="
        echo ""
        
        check_auto_restart_script
        check_bot_status
        check_logs
        show_uptime
        
        echo "Refreshing in 10 seconds..."
        sleep 10
    done
}

# Function untuk quick status
quick_status() {
    # Auto restart script
    if ps aux | grep -v grep | grep -q "auto_restart"; then
        print_status $GREEN "✓ Auto restart script: RUNNING"
    else
        print_status $RED "✗ Auto restart script: NOT RUNNING"
    fi
    
    # Bot status
    if [ -f "$PID_FILE" ] && kill -0 $(cat $PID_FILE) 2>/dev/null; then
        pid=$(cat $PID_FILE)
        elapsed=$(ps -o etime= -p $pid 2>/dev/null | tr -d ' ')
        print_status $GREEN "✓ Bot: RUNNING (PID: $pid, Uptime: $elapsed)"
    else
        print_status $RED "✗ Bot: NOT RUNNING"
    fi
    
    # Recent activity
    if [ -f "$LOG_FILE" ] && find "$LOG_FILE" -mmin -2 >/dev/null 2>&1; then
        print_status $GREEN "✓ Recent activity: YES"
    else
        print_status $YELLOW "⚠ Recent activity: NO"
    fi
}

# Function untuk show help
show_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  status    - Show full status check"
    echo "  quick     - Show quick status summary"
    echo "  live      - Live monitoring mode"
    echo "  logs      - Show recent logs only"
    echo "  kill      - Kill all bot processes"
    echo "  restart   - Restart the bot manually"
    echo "  help      - Show this help"
    echo ""
}

# Function untuk kill all processes
kill_all() {
    echo "Killing all bot processes..."
    pkill -f "auto_restart" 2>/dev/null
    pkill -f "AnonXMusic" 2>/dev/null
    rm -f "$PID_FILE" 2>/dev/null
    print_status $YELLOW "All processes killed"
}

# Function untuk manual restart
manual_restart() {
    echo "Manual restart..."
    kill_all
    sleep 3
    
    echo "Starting auto restart script..."
    if [ -f "auto_restart.py" ]; then
        screen -dmS botmanager python3 auto_restart.py
        print_status $GREEN "Started Python auto restart script in screen"
    elif [ -f "auto_restart.sh" ]; then
        screen -dmS botmanager ./auto_restart.sh
        print_status $GREEN "Started Bash auto restart script in screen"
    else
        print_status $RED "No auto restart script found!"
    fi
}

# Main script
case "${1:-status}" in
    status)
        check_auto_restart_script
        check_bot_status
        check_sessions
        check_logs
        check_network
        check_resources
        show_uptime
        ;;
    quick)
        quick_status
        ;;
    live)
        live_monitor
        ;;
    logs)
        check_logs
        ;;
    kill)
        kill_all
        ;;
    restart)
        manual_restart
        ;;
    help)
        show_help
        ;;
    *)
        show_help
        ;;
esac