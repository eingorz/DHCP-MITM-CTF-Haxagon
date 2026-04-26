#!/bin/bash

# flush docker default networking and replace with our own static
ip address flush dev eth1

ip address add 192.168.0.`shuf -i 129-199 -n 1`/24 dev eth1
ip route add default via 192.168.0.1 dev eth1
