#!/bin/bash

check() {
if [ ! -d /etc/j3ck ]
then
mkdir /etc/j3ck
fi

if [ ! -f /bin/j3ck ]
then
cp j3ck.sh /bin/j3ck
chmod +x /bin/j3ck
fi

}

main() {
while [ $exit == "false" ]
do
clear
echo "---------------------------------------------------"
printf "===================================================\n"
printf "         /\$\$\$\$\$  /\$\$\$\$\$\$            /\$\$       \n"
printf "        |__  \$\$ /\$\$__  \$\$          | \$\$       \n"
printf "           | \$\$|__/  \ \$\$  /\$\$\$\$\$\$\$| \$\$   /\$\$ \n"
printf "           | \$\$   /\$\$\$\$\$/ /\$\$_____/| \$\$  /\$\$/ \n"
printf "      /\$\$  | \$\$  |___  \$\$| \$\$      | \$\$\$\$\$\$/  \n"
printf "     | \$\$  | \$\$ /\$\$  \ \$\$| \$\$      | \$\$_  \$\$  \n"
printf "     |  \$\$\$\$\$\$/|  \$\$\$\$\$\$/|  \$\$\$\$\$\$\$| \$\$ \  \$\$ \n"
printf "      \______/  \______/  \_______/|__/  \__/ \n"
printf "====================================================\n"
echo "---------------------------------------------------"

#printf "\\e[1;93m[\\e[0m\\e[1;77m02\\e[0m\\e[1;93m] Start\\e[0m\\n"
printf " 1) MAC Spoofing		 2) NMAP Scan  \n"
printf " 3) SSH without password	 4) Palgo - Password Algorythm\n"
printf " 5) IP\n"
printf "89) Update			99) Exit \n"

read o
case "$o" in
"exit"|"q")
exit=true
;;
1)
mac
;;
2)
nmapc
;;
3)
sshpw
;;
4)
palgo
;;
5)
ipa
;;
89)
update
;;
99)
exit
;;
*)
;;
esac
done
}

start() {
exit="false"
main
}

update() {
clear
git clone https://github.com/jeckin/J3ck j3ck
rm /bin/J
chmod +x j3ck/install.sh
j3ck/install.sh
rm -r j3ck
}

ipa() {
clear
echo "1) Get Public IP"
echo "2) Forwarding Ports"
read t
case "$t" in
1)
curl icanhazip.com
read temp
;;
2)
echo "Name:"
read name
echo "IP"
read ip
echo "Port:"
read ports
echo "ssh -o ServerAliveInterval=60 -R $name:$ports:$ip:$ports serveo.net" > /bin/forward-$name-$port
chmod +x /bin/forward-$name-$port
screen /bin/forward-$name-$port
;;
esac
}

palgo() {
git || apt-get install git || pkg install git || zypper install git
python --version || apt-get install python || pkg install python || zypper install python
clear
if [[ ! -d /etc/j3ck ]]
then
if [[ ! -d Palgo ]]
then
git clone https://github.com/jeckin/Palgo
fi
d="."
else
if [[ ! -d /etc/j3ck/Palgo ]]
then
git clone https://github.com/jeckin/palgo /etc/j3ck/Palgo
fi
d="/etc/j3ck/Palgo"
fi
clear
echo "small or big? (s/b)"
read q
case "$q" in
"s" | "S")
python $d/palgo-small.py
;;
"b" | "B")
python $d/palgo-big.py
;;
esac
echo ""
read temp
}

sshpw() {
clear
if [[ ! -f ~/.ssh/id_rsa ]] && [[ ! -f ~/.ssh/id_rsa.pub ]]
then
ssh-keygen -t rsa
fi
clear
echo "User:"
read user
echo "IP:"
read ip
echo "Port (22):"
read port
if [[ $port == "" ]]
then
port="22"
fi
ssh -p $port $user@$ip mkdir .ssh
cat ~/.ssh/id_rsa.pub | ssh -p $port $user@$ip 'cat >> ~/.ssh/authorized_keys'
echo "Finished"
echo "press enter to test"
echo "or do: SSH -p $port $user@$ip"
ssh -p $port $user@$ip
}

nmapc() {
nmap || apt-get install nmap -y || zypper install nmap || pkg install nmap
nmape="false"
safe=""
clear
ip addr
echo "============================================"
echo "IP (for IP Network Scan: 192.168.XXX.1/XX):"
read ip
n=""
while [ $nmape == "false" ]
do
t=""
clear
echo "Command: NMAP $n $ip $safe"
echo "1) Scan All"
echo "2) Script Scan"
echo "3) Ping Scan"
echo "4) OS Scan"
echo "5) Scan IPv6"
echo "6) Scan specific Ports"
echo "7) Verbose option"
echo "8) Safe in file"
echo "98) Clear"
echo "99) Cancel"
echo "Enter) Start"
read t
case "$t" in
1)
n+=" -A "
;;
2)
n+=" -sC "
;;
3)
n+=" -sP "
;;
4)
n+=" -O "
;;
5)
n+=" -6 "
;;
6)
clear
echo "Only one Port Option"
echo "Ports:"
read p
n+=" -p$p "
;;
7)
echo "================================================"
echo "write v for verbose an more for a greater effect"
read v
n+=" -$v "
;;
8)
echo "Filename:"
read file
safe=" > $file"
;;
98)
n=""
;;
99)
echo "Canceled"
nampe="true"
;;
*)
echo "Press enter to Start"
nmape="true"
read temp
clear
nmap $n $ip $safe
echo "==================="
echo "press enter..."
read temp
;;
esac
done

}

mac() {
macchanger || apt-get install macchanger -y || zypper install macchanger || pkg install macchanger
clear
ip addr
echo "==================="
echo "Inteface:"
read i
clear
macchanger -s $i
echo "==============================="
echo "1) Change MAC to specific MAC"
echo "2) Change MAC to random MAC"
echo "3) Change MAC to Original MAC"
read a
case "$a" in
1)
echo "New MAC ( like 0A:1B:2C:3D:4E:5F): "
read m
ip link set dev $i down
ip link set dev $i address $m
ip link set dev $i up
clear
macchanger -s $i
read temp
;;
2)
ip link set dev $i down
macchanger -r $i
ip link set dev $i up
macchanger -s $i
read temp
;;
3)
ip link set dev $i down
macchanger -p $i
ip link set dev $i up
macchanger -s $i
read temp
;;
esac

}

start
