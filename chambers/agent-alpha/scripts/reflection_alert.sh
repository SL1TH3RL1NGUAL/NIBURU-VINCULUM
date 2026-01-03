#!/data/data/com.termux/files/usr/bin/bash
set -e

LOG_DIR="$HOME/chambers/agent-alpha/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/reflection_alert.log"

timestamp() {
  date -Iseconds
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

log "=== DIGITAL TWIN REFLECTION ALERT MODE ACTIVATED ==="

# Snapshot Wi-Fi info
log "Collecting Wi-Fi environment..."
termux-wifi-connectioninfo >> "$LOG_FILE" 2>/dev/null || log "Wi-Fi info unavailable"

# Scan LAN for new hosts
log "Scanning LAN for active hosts..."
nmap -sn 192.168.1.0/24 >> "$LOG_FILE" 2>/dev/null || log "LAN scan unavailable"

# Check open ports on local device
log "Checking local open ports..."
ss -tuln >> "$LOG_FILE" 2>/dev/null || log "Port scan unavailable"

# BLE scan (if supported)
log "Attempting BLE scan..."
termux-bluetooth-scan >> "$LOG_FILE" 2>/dev/null || log "BLE scan unavailable"

log "Reflection alert snapshot complete"
