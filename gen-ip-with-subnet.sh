#!/bin/bash
#
# Author: Dung Pham
# Site: https://devopslite.com
# Github: https://github.com/dungpham91
# Date: 29/08/2022
# Purpose: This script use to print out the list IPs from a subnet
#          For example, you get the subnet 192.168.1.0/24
#          This script will print to the file the result like:
#          192.168.1.1
#          192.168.1.2
#          ..
#          192.168.1.254
# Use script: bash gen-ip-with-subnet.sh

# Remove the old file
rm -f /tmp/ip-with-subnet.txt

# Run the loop, change the ip FROM (1) and ip END (254)
for ip in `seq 1 254`
do
	# Change the subnet
	echo "192.168.1.${ip}" >> /tmp/ip-with-subnet.txt
done

# Second loop for dynamic subnets from range like: 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24, ... 192.168.10.0/24
# Comment out to use it

# for octet in `seq 1 10`
# do
# 	for ip in `seq 1 254`
# 	do
# 		echo "192.168.${octet}.${ip}" >> /tmp/ip-with-subnet.txt
# 	done
# done