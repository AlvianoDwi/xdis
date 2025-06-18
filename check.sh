#!/bin/bash

# Simple check script untuk auto restart
echo "========================================"
echo "🤖 AnonXMusic Bot Status Check"
echo "========================================"

# Check auto restart script
echo "📋 Auto Restart Script:"
if pgrep -f "auto_restart" > /dev/null; then
    echo "✅ RUNNING"
    pgrep -f "auto_restart" | while read pid; do
        uptime=$(ps -o etime= -p $pid | tr -d ' ')
        echo "   PID: $pid, Uptime: $uptime"
    done
else
    echo "❌ NOT RUNNING"
fi

echo ""

# Check bot
echo "🎵 Bot Process:"
if pgrep -f "AnonXMusic" > /dev/null; then
    echo "✅ RUNNING"
    pgrep -f "AnonXMusic" | while read pid; do
        uptime=$(ps -o etime= -p $pid | tr -d ' ')
        echo "   PID: $pid, Uptime: $uptime"
    done
else
    echo "❌ NOT RUNNING"
fi

echo ""

# Check screen/tmux
echo "📺 Sessions:"
screen_count=$(screen -ls 2>/dev/null | grep -c "botmanager\|anonx" || echo "0")
tmux_count=$(tmux list-sessions 2>/dev/null | grep -c "botmanager\|anonx" || echo "0")
echo "Screen: $screen_count sessions | Tmux: $tmux_count sessions"

echo ""

# Check logs
echo "📄 Log Activity:"
if [ -f "bot.log" ]; then
    last_log=$(tail -1 bot.log 2>/dev/null)
    if [ ! -z "$last_log" ]; then
        echo "Latest: $last_log"
    else
        echo "❌ Empty log file"
    fi
else
    echo "❌ No log file found"
fi

if [ -f "bot_manager.log" ]; then
    last_manager_log=$(tail -1 bot_manager.log 2>/dev/null)
    if [ ! -z "$last_manager_log" ]; then
        echo "Manager: $last_manager_log"
    fi
fi

echo ""

# System info
echo "💻 System:"
echo "Memory: $(free -h | awk 'NR==2{printf "%s/%s", $3,$2}')"
echo "Uptime: $(uptime -p)"

echo "========================================"