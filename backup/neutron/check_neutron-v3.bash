#!/bin/bash
###
#
# Check Neutron Service
# Author: HoangDH - daohuyhoang87@gmail.com
# Release: 23/8/2017 - 3:28PM
#
###

check_on_other_node() {
source ~/keystonerc_admin
neutron agent-list >> /tmp/info_neutron.h2
services=`cat /tmp/info_neutron.h2 | grep -w "xxx" | awk  '{ print $8 }' FS="|" | sort -u`

for service in $services
	do
		node=`cat /tmp/info_neutron.h2 | grep -w "xxx" | grep -w "$service" | awk  '{ print $4 }' FS="|" | sort -u`
		echo -e "$node:\t$service" >> /tmp/err_neutron.h2
	done
}

i=0
f=$(systemctl status neutron-server | grep 'active (running)')
if [ -z "$f" ]
	then
		i=0
	else
		check_on_other_node
		if [ -e /tmp/err_neutron.h2 ]
		then
			i=$(cat /tmp/err_neutron.h2 | wc -l)
		else 
			i=9999999
		fi
fi

rm -rf /tmp/info_neutron.h2

case $i in
	99999)
		echo "OK. Neutron-server is running."
		exit 0
		;;
	[1-99998]*)
		s=`cat /tmp/err_neutron.h2` 
		rm -rf /tmp/err_neutron.h2
		echo -e "WARNING. Neutron-agent is/are not running.\n$s"
		exit 1
		;;	
	0) 
		echo "CIRTICAL. Neutron-server is not running."
		exit 2
		;;
	*)
		echo "UNKNOWN. Neutron-server or agent is/are not running."
		exit 3
		;;	
esac

	