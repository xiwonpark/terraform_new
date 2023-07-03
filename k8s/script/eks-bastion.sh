#!/bin/bash
# Set Variables
LOG_FILE=/var/log/script.log
MAX_ATTEMPTS=5
HOME=/root

# OS Setting
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
hostnamectl set-hostname eks-bastion
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config
sudo systemctl stop firewalld && systemctl disable firewalld
setenforce 0

# Ping Test
ping_google() {
  ping -c 4 google.com >/dev/null 2>&1
  return $?
}

for attempt in $(seq $MAX_ATTEMPTS); do
  if ping_google; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') ping succeeded on attempt $attempt" >> $LOG_FILE
    echo "Success!"
    break
  else
    echo "$(date +'%Y-%m-%d %H:%M:%S') ping failed on attempt $attempt" >> $LOG_FILE
    echo "Ping failed, retrying in 10 seconds..."
    sleep 10
  fi
done

if [ $attempt -eq $MAX_ATTEMPTS ]
then 
  echo "Ping failed after $MAX_ATTEMPTS attempts"
  exit 1
fi

# Install kubectl
curl https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.10/2023-01-30/bin/linux/amd64/kubectl -o $HOME/kubectl
if [ $? -eq 0 ] && [ -e $HOME/kubectl ]; then
  chmod +x $HOME/kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') kubectl download failed" >> $LOG_FILE
  exit 1
fi

mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

# Install aws cli v2
ping -q -c 1 google.com >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S') Internet Connection is not Available" >> $LOG_FILE
  exit 1
fi

yum install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
if [ $? -eq 0 ] && [ -e ./awscliv2.zip ]
then
  unzip ./awscliv2.zip
  if [ $? -eq 0 ]
  then
    ./aws/install
  fi
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') awscli download failed" >> $LOG_FILE
  exit 1
fi

aws configure set aws_access_key_id "ACCESS_KEY_ID" && aws configure set aws_secret_access_key "SECRET_KEY" && aws configure set region "ap-northeast-2"
if [ $? -ne 0 ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S') aws configure set failed" >> $LOG_FILE
  exit 1
fi

# Install eksctl
if ping -q -c 1 google.com >/dev/null 2>&1
then
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  if [ $? -eq 0 ] && [ -e /tmp/eksctl ]
  then
    mv /tmp/eksctl /usr/local/bin
  fi
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') Internet Connection is not Available" >> $LOG_FILE
  exit 1
fi

# Create EKS Cluster
echo '''apiVersion: eksctl.io/v1alpha5
Kind: ClusterConfig

metadata:
  name: tftest-eks
  region: ap-northeast-2
  version: "1.24"

iam:
  withOIDC: true

vpc:
  subnets:
    private:
      ap-northeast-2a: { id: "${var.public_subnets_id_a}" }
      ap-northeast-2c: { id: "${var.public_subnets_id_c}" }

managedNodeGroups:
  - name: tftest-ng
    instanceType: t3.large
    instanceName: tftest-ec2
    privateNetworking: true
# AutoScaling
    minSize: 2
    maxSize: 4
    desiredCapacity: 2
# Volume
    volumeType: gp3
    volumeSize: 20''' >> $HOME/eks.yaml

if [ -e $HOME/eks.yaml ]
then
  eksctl create cluster -f $HOME/eks.yaml
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') eks create failed" >> $LOG_FILE
fi

if [ $? -eq 0 ]
then
  echo "$(date +'%Y-%m-%d %H:%M:%S') Cluster Setup Completed with eksctl command"
  exit 0
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') Cluster Setup Failed while running eksctl command" >> $LOG_FILE
  exit 1
fi
