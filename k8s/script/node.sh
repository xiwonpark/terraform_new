#!/bin/bash
# Variables
YYMMDD=`date +"%y%m%d"`
sysctl_k8s=/etc/sysctl.d/k8s.conf
kube_repo=/etc/yum.repos.d/kubernetes.repo
error_log=/var/log/sw_error.log

# OS Setting
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo hostnamectl set-hostname master
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
systemctl stop firewalld && systemctl disable firewalld

# Disable selinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

# Swap OFF
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Iptables setup
if [ ! -e $iptables_sysctl_k8s ]
then
  sudo modprobe overlay
  sudo modprobe br_netfilter
  touch $iptables_sysctl_k8s
  echo """net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1""" > $iptables_sysctl_k8s
  sysctl --system
else
  `echo $YYMMDD iptables_sysctl_error >> $error_log`
fi

# Hosts file setup
echo """
10.0.20.21      master
10.0.20.22      node01
10.0.20.23      node02""" >> /etc/hosts

# Yum update
ping -c 4 8.8.8.8
if [ $? -eq 0 ]
then
  yum update -y
else
  `echo $YYMMDD yum update error >> $error_log`
fi

# Kube repo setup
if [ ! -e $kube_repo ]
then
  touch $kube_repo
  echo """[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg""" > $kube_repo
else
  `echo $YYMMDD kube_repo error >> $error_log`
fi

# Install kubeadm kubelet kubectl
if [ $? -eq 0 ] 
then
  sudo yum clean all && sudo yum -y makecache
  sudo yum -y install epel-release vim git curl wget kubelet kubeadm kubectl --disableexcludes=kubernetes
else
  `echo $YYMMDD docker start error >> $error_log`
fi


# Install containerd required pkgs
if [ $? -eq 0 ]
then
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
else
  `echo $YYMMDD install containerd error >> $error_log`
fi

# Install containerd
if [ $? -eq 0 ]
then
  sudo yum update -y && yum install -y containerd.io
else
  `echo $YYMMDD install containerd error >> $error_log`
fi

# Configure containerd and start service
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

if [ $? -eq 0 ]
then
  reboot
fi