#!/bin/bash
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo hostnamectl set-hostname "${var.D_project_hostname[count.index]}"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd