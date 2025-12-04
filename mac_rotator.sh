#!/bin/bash

INTERFACES=($(ip link show | grep -E '^[0-9]+:' | cut -d: -f2 | tr -d ' ' | grep -v lo))

rotate_mac() {
    local interface=$1
    echo "[+] Rotating MAC address for $interface"
    
    # Bring interface down
    sudo ip link set dev $interface down
    
    # Change MAC address
    sudo macchanger -r $interface
    
    # Bring interface back up
    sudo ip link set dev $interface up
    
    # Verify change
    echo "[+] New MAC address:"
    macchanger -s $interface
}

# Kill network processes that might interfere
sudo systemctl stop NetworkManager
sudo pkill -f dhclient
sudo pkill -f wpa_supplicant

# Rotate all available interfaces
for iface in "${INTERFACES[@]}"; do
    if [[ $iface != "lo" ]]; then
        rotate_mac $iface
    fi
done

# Restart network services
sudo systemctl start NetworkManager

echo "[+] MAC address rotation complete"
