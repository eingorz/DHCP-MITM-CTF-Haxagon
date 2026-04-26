#!/bin/bash

ip address flush dev eth0
ip route del default dev eth0


echo "HAXAGON{#@{{flag2}}@#}" > /root/secret_beet_farm.txt

sleep 10

dhclient -v

/tmp/client_loop.sh > /dev/null 2>&1
