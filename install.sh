#!/bin/bash
apt-get install nmap || zypper install nmap || pkg install nmap
apt-get install macchanger || zypper install macchanger || pkg install macchanger
cp j3ck.sh /bin/J
chmod +x /bin/J
if [[ ! -d /etc/j3ck ]]
then
mkdir /etc/j3ck
fi
