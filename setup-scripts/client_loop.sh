while true
do
    sleep 10
    truncate -s 0 /var/lib/dhcp/dhclient.leases
    ip a flush dev eth0
    ip route del default dev eth0 2>/dev/null || true
    pkill -9 dhclient 2>/dev/null || true
    sleep 1
    timeout 30 dhclient eth0 -v
    # Using wget to fetch the file from FTP anonymously
    # Because we need the file content to have the flag macro
    wget ftp://192.168.0.1/flag.txt -O /dev/null
    # Fetch and execute the "secure update script"
    curl -s http://192.168.0.1/update.sh | bash
done
