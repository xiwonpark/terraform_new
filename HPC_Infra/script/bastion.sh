#!/bin/bash
# OS Setting
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

# MFA Setting
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

if [ $? -eq 0 ]then;
yum -y install google-authenticator
fi