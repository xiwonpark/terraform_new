#!/bin/bash
# Variables
YYMMDD=`date +"%y%m%d"`
iptables_module_load_k8s_conf=/etc/modules-load.d/k8s.conf
iptables_sysctl_k8s_conf=/etc/sysctl.d/k8s.conf
kube_repo=/etc/yum.repos.d/kubernetes.repo
docker_daemon_json=/etc/docker/daemon.json
error_log=/var/log/sw_error.log

# OS Setting
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo hostnamectl set-hostname master
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
systemctl stop firewalld && systemctl disable firewalld
touch $error_log

# Swap OFF
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Module_load setting
if [ ! -e $iptables_module_load_k8s_conf ]
then
  touch $iptables_module_load_k8s_conf
  echo br_netfilter > $iptables_module_load_k8s_conf
else
  echo $YYMMDD iptables_module_load_k8s.conf error >> $error_log
fi

if [ ! -e $iptables_sysctl_k8s_conf ]
then
  touch $iptables_sysctl_k8s_conf
  echo """net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1""" > $iptables_sysctl_k8s_conf
  sysctl --system
else
  echo $YYMMDD iptables_sysctl_error >> $error_log
fi

# Hosts file setup
echo """
${var.k8s_master_ip}      master
${var.k8s_nodes_ip[0]}    ${var.k8s_nodes[0]}
${var.k8s_nodes_ip[1]}    ${var.k8s_nodes[1]}
""" >> /etc/hosts

# Yum update
ping -c 4 8.8.8.8
if [ $? -eq 0 ]
then
  yum update -y
else
  echo $YYMMDD yum update error >> $error_log
fi

# Kube repo setup
if [ ! -e $kube_repo ]
then
  touch $kube_repo
  echo """[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg""" > $kube_repo
else
  echo $YYMMDD kube_repo error >> $error_log
fi

# Install docker
curl -s https://get.docker.com | sudo sh
if [ $? -eq 0 ]
then
  systemctl enable docker && systemctl start docker
else
  echo $YYMMDD docker start error >> $error_log
fi

# Docker daemon setup
if [ ! -e $docker_daemon_json ]
then
  echo """{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}""" > $docker_daemon_json
else
  echo docker daemon json error >> $error_log
fi

systemctl restart docker

# Install kubectl
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

if [ $? -eq 0 ]
then
  kubeadm init
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
else
  echo $YYMMDD kubeadmin init error >> $error_log
fi

systemctl enable kubelet
systemctl start kubelet

# Reboot
if [ $? -eq 0 ]; then
  init 6
else
  echo $YYMMDD Reboot error >> $error_log
fi