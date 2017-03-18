#! /bin/bash

CURUSER=$(whoami)
if [[ E${CURUSER} != "Eroot" ]]; then
	echo "must be root"
	exit 1
fi

SFUSER="guest"
SFPASSWORD="IBERamPO"

LOGFILE=/home/pi/pi_auto_con/log.txt
echo "login_to_salesforce_slave.sh start" >> ${LOGFILE}

#As this is launched on startup wait 3 seconds to ensure network etc is up
sleep 3
cd /home/pi/pi_auto_con/

TESTHOST=google.com

iwconfig wlan0 essid NOSOFTWARE
dhclient
sleep 3
GOTINTERNET=$(ping -q -w 1 -c 1 ${TESTHOST} > /dev/null 2>&1 && echo ONLINE || echo OFFLINE)
echo "Initial network state = ${GOTINTERNET}" >> ${LOGFILE}
if [[ E${GOTINTERNET} == "EOFFLINE" ]]; then
	echo "Attempting to login" >> ${LOGFILE}
	wget -O /home/pi/pi_auto_con/sf_login.html https://guest.corp.salesforce.com/login.html --post-data "buttonClicked=4&err_flag=0&err_msg=&info_flag=0&info_msg=&redirect_url=&network_name=Guest%20Network&username=${SFUSER}&password=${SFPASSWORD}" >> ${LOGFILE} 2>&1
	sleep 3
	GOTINTERNET=$(ping -q -w 1 -c 1 ${TESTHOST} > /dev/null 2>&1 && echo ONLINE || echo OFFLINE)
	if [[ E${GOTINTERNET} == "EOFFLINE" ]]; then
		echo "ERROR - Login form post failed to get us internet connection" >> ${LOGFILE}
		exit 1
	fi
	
fi

IPADDR=$(/sbin/ifconfig wlan0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
CURDATE=$(date)
echo "IP=${IPADDR}" >> ${LOGFILE}

if [[ ${#IPADDR} -lt 2 ]]; then
	echo "ERROR Bad IP Address" >> ${LOGFILE}
	exit 1
fi

echo "sending ${IPADDR} at ${CURDATE}" >> ${LOGFILE}
wget -O /dev/null https://maker.ifttt.com/trigger/pi_online/with/key/b-V2xCfrEyvA81r8glGf6q?value1=${IPADDR}&value2=v2 >> ${LOGFILE} 2>&1

python3 output_text.py ${IPADDR}
python3 output_text.py ${IPADDR}
python3 output_text.py ${IPADDR}

echo "login_to_salesforce_slave.sh done" >> ${LOGFILE}
exit 0
