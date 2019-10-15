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

#printf "\\e[1;93m[\\e[0m\\e[1;77m02\\e[0m\\e[1;93m] Start\\e[0m\ \n"
printf " 1) MAC Spoofing		 2) NMAP Scan  \n"
printf " 3) SSH without password	 4) Palgo - Password Algorythm \n"
printf " 5) IP				 6) EasyCrontab \n"
printf " 7) Loop Task 			 8) PPTP VPN\n"
printf " 9) Port Forwarding 		10) Mount Server\n"
printf "89) Update/Install			99) Exit \n"

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
6)
easycrontab
;;
7)
loop
;;
8)
vpn
;;
9)
port
;;
10)
mntsrv
;;
89)
update
;;
99)
clear
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

mntsrv() {
clear
echo "1a) WEBDAV Server once 1b) permanent"
echo "2) SFTP Server"
echo "3) FTP Server"
read t
case "$t" in
1a)
sudo apt-get install davfs2 -y
clear
echo "Serverlink (https://yourcloud.com/webdav):"
read link
echo "Mount Folder (/mnt/dav): "
read folder
sudo mount -t davfs -o noexec $link $folder
exit="true"
;;
1b)
sudo apt-get install davfs2 -y
clear
echo "Mount Folder (/mnt/dav): "
read folder
echo "Serverlink (https://yourcloud.com/webdav):"
read link
if [[ $t == "1a" ]]
then
sudo mount -t davfs -o noexec $link $folder || echo "Error"
else
clear
echo "User:"
read $user
echo "Password (Warning cleartext):"
read $pass
echo "$link $folder davfs _netdev,noauto,user,uid=$user 0 0" >> /etc/fstab
echo "$folder $user $pass" >> /etc/davfs2/secrets
mount $folder
clear
echo "Mount on reboot(Y/n)?"
read n
if [[ ! $n == "n" ]]
then
echo "@reboot	root	mount /mnt/$name" >> /etc/crontab

fi
fi
exit="true"
;;
2)
sudo apt-get install sshfs
clear
echo "IP or Hostname:"
read ip
echo "User:"
read user
echo "Path on the Server:"
read paths
echo "Mount path"
read pathm
sshfs $user@$ip:$paths $pathm
;;
3)
sudo apt-get install curlftpfs
clear
echo "User:"
read user
echo "Password (Warning Cleartext!):"
read pass
echo "Hostname:"
read hostname
echo "Mount path"
read path
curlftpfs $user:$pass@$hostname $path
pass=""
df -h
read temp
exit="true"
;;
esac
}

port() {
clear
echo "1) IPv4 Port Forwarding"
echo "2) IPv6 Port Forwarding - (comming soon)"
echo "3) Show Forwarding Ports"
read t
case "$t" in
1)
portipv4
;;
2)
portipv6
;;
3)
iptables -t nat -L -n -v
echo "=============="
echo "Press enter..."
read temp
;;
esac
}

portipv4() {
clear
echo "From IP:"
read ipone
echo "From Port:"
read portone
echo "To IP:"
read iptwo
echo "To Port:"
read porttwo
echo "TCP or UDP? (1=TCP,2=UDP)"
read tu
if [[ $tu == "1" ]]
then
tcpudp="tcp"
else
tcpudp="udp"
fi
sysctl net.ipv4.ip_forward=1
sysctl -p
iptables -t nat -A PREROUTING -p $tcpudp -d $ipone --dport $portone -j DNAT --to-destination $iptwo:$porttwo
iptables -t nat -A POSTROUTING -j MASQUERADE
clear
echo "Finished - Press enter..."
read temp
}

vpn() {
clear
echo "1) Create PPTP VPN"
echo "2) Create Connection PPTP VPN"
echo "3) Start Connection to PPTP VPN"
echo "4) Stop Connection to PPTP VPN"
echo "5) Show Connection"
read t
case "$t" in
1)
vpn1
;;
2)
vpn2
;;
3)
pon vpn
tail -f /var/log/messages -n 50 | grep pppd
;;
4)
poff vpn
tail -f /var/log/messages -n 50 | grep pppd
;;
5)
tail -f /var/log/messages | grep pppd
;;
esac
}

vpn1() {
clear
echo "Warning it only tested on Ubuntu"
echo "press enter to start..."
read temp
apt-get install pptpd
echo "localip 192.168.1.5
remoteip 192.168.1.234-238,192.168.1.245" >> /etc/pptpd.conf
echo "ms-dns 192.168.1.1
nobsdcomp
noipx
mtu 1490
mru 1490" >> /etc/ppp/pptd-options
clear
echo "Username:"
read username
echo "Password (clear-text):"
read pass
echo "$username	*	$pass	*" >> /etc/ppp/chap-secrets
sudo /etc/init.d/pptpd restart
clear
echo "Enable IPv4 forwarding?(Y/n)"
read y
if [[ $y == "n" ]]
then
echo ""
else
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo sysctl -p
fi
clear
echo "Finished!"
echo "Connect with:"
echo "Username: $username"
echo "Password: $pass"
exit="true"
}

vpn2() {
clear
echo "Warning it isnt complete tested"
read temp
if [[ ! -f /etc/ppp/peers/vpn ]]
then
sudo apt-get -y install pptp-linux
echo "Server:"
read server
echo "Username:"
read username
echo "Password (clear-text):"
read password
echo "$username	vpn	$password	*" >> /etc/ppp/chap-secrets
echo "pty \"pptp $server --nolaunchpppd\"
name $username
remotename vpn
require-mppe-128
file /etc/ppp/options.pptp
ipparam vpn" > /etc/ppp/peers/vpn
echo "#!/bin/bash

if [ \"\$PPP_IPPARAM\" == \"vpn\" ]; then
        route add -net 192.168.1.1/24 dev \$PPP_IFACE
fi" > /etc/ppp/ip-up.d/99vpnroute
sudo chmod +x /etc/ppp/ip-up.d/99vpnroute
pon vpn
tail -f /var/log/messages | grep pppd
fi
}

loop() {
clear

if [[ ! -f /bin/task ]]
then
echo "#!/bin/bash
clear
echo "Task"
read task
clear
echo "Time"
read time
while true
do
        clear
        \$task
        sleep \$time
done
" > /bin/task
chmod +x /bin/task
echo "Done"
echo "Do 'task' to Start a task"
read temp
else
clear
echo "Task"
read task
clear
echo "Time"
read time
while true
do
        clear
        $task
        sleep $time
done
fi

}

easycrontab() {
clear
git clone https://github.com/jeckin/easycrontab
chmod +x easycrontab/install.sh
easycrontab/install.sh
read temp
rm -r easycrontab
exit="true"
}

update() {
clear
git clone https://github.com/jeckin/J3ck /tmp/j3ck
rm /bin/J
####Install####
apt-get install nmap || zypper install nmap || pkg install nmap
apt-get install macchanger || zypper install macchanger || pkg install macchanger
cp /tmp/j3ck/j3ck.sh /bin/J
sudo chmod +x /bin/J
###############
rm -r /tmp/j3ck
}

ipa() {
clear
echo "1)    Get Public IP"
echo "2)    Forwarding Ports"
echo "3on)  Set Interface on		3off) Set Interface off "
echo "4add) Add IP to Interface		4del) Del IP from Interface"
echo "5)    Flush Interface"
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
3on)
clear
ip addr
echo "==========="
echo "Interface:"
read int
ip link set dev $int down
;;
3off)
clear
ip addr
echo "==========="
echo "Interface:"
read int
ip link set dev $int up
;;
4add)
clear
ip addr
echo "==========="
echo "Interface:"
read int
echo "IP:"
read ip
ip addr add dev $int $ip
;;
4del)
clear
ip addr
echo "==========="
echo "Interface:"
read int
echo "IP:"
read ip
ip addr del dev $int $ip
;;
5)
clear
ip addr
echo "==========="
echo "Interface:"
read int
echo "are you sure? (y/N)"
read sure
if [[ $sure == "y" ]]
then
ip addr flush dev $int
fi
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
echo "Command: nmap $n $ip $safe"
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
