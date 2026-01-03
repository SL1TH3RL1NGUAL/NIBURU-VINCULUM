#!/data/data/com.termux/files/usr/bin/bash

echo "[CHAMBER] Mapping inbound/outbound connectivity..."

ss -tulnp > ~/chamber/network/ports.txt
netstat -an > ~/chamber/network/connections.txt
nmap -sV localhost > ~/chamber/network/nmap_local.txt

echo "[CHAMBER] Connectivity map updated."
