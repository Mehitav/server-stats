#!/bin/bash
# server-stats.sh
# The simplest monitoring to check server performance
echo "======================"
echo " Server Performance Stats"
echo "======================"
echo

# --- CPU Usage ---
echo ">>> CPU Usage:"
# %idle is taken from mpstat and we calculate %usage from it
if command -v mpstat >/dev/null 2>&1; then
    cpu_idle=$(mpstat 1 1 | awk '/Average:/ && $12 ~ /[0-9.]+/ {print $12}')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)
    echo "Total CPU Usage: $cpu_usage %"
else
    echo "mpstat not installed, showing from top:"
    top -bn1 | grep "Cpu(s)"
fi
echo

# --- Memory Usage ---
echo ">>> Memory Usage:"
free -h | awk '/Mem:/ {printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $3/$2 * 100}'
echo

# --- Disk Usage ---
echo ">>> Disk Usage:"
df -h --total | awk '/total/ {printf "Used: %s / Total: %s (%s Used)\n", $3, $2, $5}'
echo

# --- Top 5 processes by CPU ---
echo ">>> Top 5 processes by CPU:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
echo

# --- Top 5 processes by Memory ---
echo ">>> Top 5 processes by Memory:"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6
echo

# --- Stretch goals ---
echo ">>> Extra Info:"
echo "OS Version:"; lsb_release -d 2>/dev/null || cat /etc/*release | head -n 1
echo "Uptime:"; uptime -p
echo "Load average:"; uptime | awk -F'load average:' '{print $2}'
echo "Logged in users:"; who | wc -l
echo "Failed login attempts (last 10):"; lastb | head -n 10 2>/dev/null || echo "No failed logins log available"
