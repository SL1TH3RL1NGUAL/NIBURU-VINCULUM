#!/data/data/com.termux/files/usr/bin/bash

# ================================
#  CHAMBER ENGINE – DIAGNOSTICS
# ================================

LOG_DIR="$HOME/chamber/logs"
mkdir -p "$LOG_DIR"

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

banner() {
  clear
  echo "========================================="
  echo "        CHAMBER ENGINE – TERMUX"
  echo "========================================="
  echo
}

pause() {
  read -rp "Press ENTER to continue..."
}

# --------------------------------
# 1. System & network snapshot
# --------------------------------
snapshot_system() {
  local ts
  ts="$(timestamp)"
  local outfile="$LOG_DIR/system_snapshot_$ts.txt"

  echo "[*] Capturing system snapshot to: $outfile"
  {
    echo "===== TIMESTAMP ====="
    date
    echo

    echo "===== UNAME ====="
    uname -a
    echo

    echo "===== TERMUX-INFO ====="
    termux-info 2>/dev/null || echo "termux-info not available"
    echo

    echo "===== IP ADDR ====="
    ip addr 2>&1
    echo

    echo "===== IP ROUTE ====="
    ip route 2>&1
    echo

    echo "===== IFCONFIG ====="
    ifconfig 2>&1
    echo

  } > "$outfile"

  echo "[+] Snapshot complete."
  echo "    Saved as: $outfile"
  echo
  pause
}

# --------------------------------
# 2. Local Wi-Fi network scan
# --------------------------------
scan_local_network() {
  echo "[*] Detecting local IP and network..."
  local wlan_ip subnet base

  wlan_ip=$(ip addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | head -n1)

  if [ -z "$wlan_ip" ]; then
    echo "[!] No wlan0 IPv4 detected. Connect to Wi-Fi and try again."
    pause
    return
  fi

  subnet="${wlan_ip##*/}"    # CIDR suffix, e.g. 24
  base="${wlan_ip%/*}"       # IP without CIDR, e.g. 10.121.90.90

  IFS='.' read -r o1 o2 o3 o4 <<< "$base"
  # assume /24 for simplicity
  local network="$o1.$o2.$o3.0/24"

  echo "[*] Wi-Fi IP:   $base/$subnet"
  echo "[*] Scanning:   $network"
  echo

  local ts
  ts="$(timestamp)"
  local outfile="$LOG_DIR/nmap_scan_$ts.txt"

  nmap -sn "$network" -oN "$outfile"

  echo
  echo "[+] Scan complete."
  echo "    Saved as: $outfile"
  echo
  pause
}

# --------------------------------
# 3. Scan for common IoT / MQTT ports
# --------------------------------
scan_iot_mqtt() {
  echo "[*] Detecting local IP and network..."
  local wlan_ip subnet base

  wlan_ip=$(ip addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | head -n1)

  if [ -z "$wlan_ip" ]; then
    echo "[!] No wlan0 IPv4 detected. Connect to Wi-Fi and try again."
    pause
    return
  fi

  subnet="${wlan_ip##*/}"
  base="${wlan_ip%/*}"

  IFS='.' read -r o1 o2 o3 o4 <<< "$base"
  local network="$o1.$o2.$o3.0/24"

  echo "[*] Wi-Fi IP:   $base/$subnet"
  echo "[*] Scanning $network for IoT/MQTT-related ports..."
  echo "    Ports: 1883 (MQTT), 8883 (MQTT TLS), 5683 (CoAP), 80/443 (HTTP/HTTPS)"
  echo

  local ts
  ts="$(timestamp)"
  local outfile="$LOG_DIR/iot_mqtt_scan_$ts.txt"

  nmap -p 1883,8883,5683,80,443 "$network" -oN "$outfile"

  echo
  echo "[+] Scan complete."
  echo "    Saved as: $outfile"
  echo
  pause
}

# --------------------------------
# 4. Basic DNS & connectivity tests
# --------------------------------
connectivity_checks() {
  local ts
  ts="$(timestamp)"
  local outfile="$LOG_DIR/connectivity_$ts.txt"

  echo "[*] Running DNS & connectivity tests..."
  {
    echo "===== TIMESTAMP ====="
    date
    echo

    echo "===== PING: 1.1.1.1 ====="
    ping -c 4 1.1.1.1 2>&1 || echo "Ping failed"
    echo

    echo "===== PING: 8.8.8.8 ====="
    ping -c 4 8.8.8.8 2>&1 || echo "Ping failed"
    echo

    echo "===== DNS LOOKUP: example.com ====="
    getent hosts example.com 2>&1 || echo "DNS lookup failed"
    echo

  } > "$outfile"

  echo "[+] Connectivity tests complete."
  echo "    Saved as: $outfile"
  echo
  pause
}

# --------------------------------
# 5. Simple watch on routes / interfaces
#    (no root, limited insight, but useful)
# --------------------------------
watch_network_state() {
  echo "[*] Watching network state. Press CTRL+C to stop."
  echo

  while true; do
    clear
    echo "===== $(date) ====="
    echo
    echo "--- ip addr ---"
    ip addr | sed 's/^/  /'
    echo
    echo "--- ip route ---"
    ip route | sed 's/^/  /'
    echo
    sleep 5
  done
}

# --------------------------------
# MENU
# --------------------------------
main_menu() {
  while true; do
    banner
    echo "Choose an action:"
    echo
    echo "  1) System & network snapshot"
    echo "  2) Scan local Wi-Fi network"
    echo "  3) Scan for IoT/MQTT-related ports"
    echo "  4) DNS & connectivity checks"
    echo "  5) Live watch: network state (ip addr/route)"
    echo "  0) Exit"
    echo
    read -rp "Option: " opt

    case "$opt" in
      1) snapshot_system ;;
      2) scan_local_network ;;
      3) scan_iot_mqtt ;;
      4) connectivity_checks ;;
      5) watch_network_state ;;
      0) exit 0 ;;
      *) echo "[!] Invalid option"; sleep 1 ;;
    esac
  done
}

main_menu
