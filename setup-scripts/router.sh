#!/bin/bash

ip address flush dev eth1

ip address add 192.168.0.1/24 dev eth1

iptables -t nat -A POSTROUTING -j MASQUERADE

echo nameserver 1.1.1.1 > /etc/resolv.conf
echo "/usr/sbin/nologin" >> /etc/shells


echo "listen=YES" > /etc/vsftpd.conf
echo "anonymous_enable=YES" >> /etc/vsftpd.conf
echo "local_enable=YES" >> /etc/vsftpd.conf
echo "dirmessage_enable=YES" >> /etc/vsftpd.conf
echo "use_localtime=YES" >> /etc/vsftpd.conf
echo "xferlog_enable=YES" >> /etc/vsftpd.conf
echo "connect_from_port_20=YES" >> /etc/vsftpd.conf
echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /etc/vsftpd.conf
echo "pam_service_name=vsftpd" >> /etc/vsftpd.conf
echo "seccomp_sandbox=NO" >> /etc/vsftpd.conf
echo "anon_root=/srv/ftp" >> /etc/vsftpd.conf
echo "no_anon_password=YES" >> /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf
echo "pasv_enable=YES" >> /etc/vsftpd.conf
echo "pasv_min_port=10000" >> /etc/vsftpd.conf
echo "pasv_max_port=10100" >> /etc/vsftpd.conf
# Gemini vymýšlel, protože jinač se to se mnou nebavilo. nebudu na to šahat :)



#tc qdisc add dev eth1 root handle 1: prio
#tc filter add dev eth1 parent 1: protocol ip u32 \
#    match ip dport 67 0xffff \
#    flowid 1:1
#tc qdisc add dev eth1 parent 1:1 netem delay 6000ms 200ms

systemctl start isc-dhcp-server
systemctl restart vsftpd
systemctl start apache2

echo 'echo "Running Dwight'\''s secure update..."' > /var/www/html/update.sh
chmod +x /var/www/html/update.sh
systemctl stop ssh

echo SCENARIO_IS_READY
