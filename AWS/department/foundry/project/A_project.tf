resource "aws_instance" "A_Project" {
  ami   = lookup("${var.ami}", "RHEL79")
  count = length(var.A_project_ip)

  vpc_security_group_ids = ["${var.sg}"]
  instance_type          = var.instance_type[0]
  subnet_id              = var.foundry_01_sn
  private_ip             = var.A_project_ip[count.index]
  disable_api_termination = true

    root_block_device {
    encrypted = true
    kms_key_id = "arn:aws:kms:ap-northeast-2:644631683002:key/67f7a0be-9372-4e65-a9e9-d1e6f362811e"
  }
  user_data = <<EOF
#!/bin/bash

# OS Setting
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo hostnamectl set-hostname "${var.A_project_hostname[count.index]}"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
EOF

  tags = merge("${var.tags}", { Name = "${var.A_project_hostname[count.index]}" })
}