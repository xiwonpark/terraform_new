#!/bin/bash
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config
sudo systemctl stop firewalld && systemctl disable firewalld
setenforce 0

yum groupinstall "Server with GUI" -y
systemctl stop firewalld
systemctl disable firewalld

systemctl isolate graphical.target
systemctl set-default graphical.target

