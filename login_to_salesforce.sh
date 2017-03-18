#! /bin/bash

CURDATE=$(date)
CURUSER=$(whoami)

if [[ E${CURUSER} != "Eroot" ]]; then
	echo "Must be root"
	exit 1
fi

echo "${CURDATE} Starting login_to_salesforce as ${CURUSER}" >> /home/pi/pi_auto_con/log.txt
/home/pi/pi_auto_con/login_to_salesforce_slave.sh > /dev/null & 
echo "login_to_salesforce done" >> /home/pi/pi_auto_con/log.txt

exit 0
