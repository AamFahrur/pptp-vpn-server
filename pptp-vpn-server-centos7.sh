#! /bin/bash

#########
# os: centos7


install_pptp() { 
  sudo yum install -y ppp
  wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo rpm -ivh epel-release-latest-7.noarch.rpm
  sudo yum repolist
  sudo yum -y update
  sudo yum install -y pptpd
}

config_kernel_IP_forwarding() {
  echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
  sudo sysctl -p
}

config_pptp() {
  sudo sed -i 's/#localip 192.168.0.1/localip 192.168.0.1/g' /etc/pptpd.conf
  sudo sed -i 's/#remoteip 192.168.0.234-238,192.168.0.245/remoteip 192.168.0.234-238,192.168.0.245/g' /etc/pptpd.conf 
  sudo sed -i 's/#ms-dns 10.0.0.1/ms-dns 8.8.8.8/g' /etc/ppp/options.pptpd
  sudo sed -i 's/#ms-dns 10.0.0.2/ms-dns 8.8.4.4/g' /etc/ppp/options.pptpd
  sudo echo "$username  pptpd  \"$password\"  *" >> /etc/ppp/chap-secrets
}

iptables_config() {
  sudo yum -y install iptables
  sudo firewall-cmd --permanent --add-masquerade
  sudo firewall-cmd --permanent --add-port=47/tcp
  sudo firewall-cmd --permanent --add-port=1723/tcp
  sudo firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p gre -j ACCEPT
  sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
  sudo firewall-cmd --reload
  sudo systemctl enable pptpd
}


# start shell.
install_pptp

read -p "Please enter the VPN connection username:" username
read -p "Please enter the VPN connection password:" password

config_kernel_IP_forwarding
iptables_config
config_pptp
sudo systemctl restart pptpd

echo -e "\npptp vpn service config success!!!"
