resource "aws_instance" "bastion" {
  ami = lookup("${var.ami}", "cent79")

  vpc_security_group_ids      = ["${var.sg}"]
  instance_type               = var.instance_type[0]
  subnet_id                   = var.public_subnets_id_a
  private_ip                  = var.bastion_ip
  associate_public_ip_address = true
  user_data                   = file("../${path.root}/script/bastion.sh")

  tags = merge("${var.tags}", { Name = "${var.name}-bastion" })
}

resource "aws_instance" "awx_controller" {
  ami = lookup("${var.ami}", "cent79")

  vpc_security_group_ids = ["${var.sg}"]
  instance_type          = var.instance_type[2]
  subnet_id              = var.private_subnets_id_a
  private_ip             = var.awx_controller_ip
  user_data              = file("../${path.root}/script/controller.sh")

  tags = merge("${var.tags}", { Name = "${var.name}-awx_controller" })
}

resource "aws_instance" "awx_nodes" {
  ami   = lookup("${var.ami}", "cent79")
  count = length("${var.awx_nodes}")

  vpc_security_group_ids = ["${var.sg}"]
  instance_type          = var.instance_type[0]
  subnet_id              = var.private_subnets_id_a
  private_ip             = var.awx_nodes_ip[count.index]
#  key_name                    = aws_key_pair.sw-tf_rsa.key_name
  depends_on             = [aws_efs_mount_target.efs_mount_target]
  user_data = <<EOF
#!/bin/bash

# OS Setting
echo 'Ezcom!234' |passwd --stdin 'root'
echo 'Ezcom!234' |passwd --stdin 'centos'
sudo hostnamectl set-hostname "${var.awx_nodes[count.index]}"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
sudo mkdir -p /user
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "${aws_efs_mount_target.efs_mount_target.ip_address}":/ /user
EOF

  tags = merge("${var.tags}", { Name = "${var.name}-${var.awx_nodes[count.index]}" })
}

resource "aws_alb_target_group_attachment" "target_group_attach_vnc" {
  target_group_arn = var.target_group_vnc
  target_id        = aws_instance.awx_nodes[1].id
  port             = 8080
}

resource "aws_alb_target_group_attachment" "target_group_attach_awx" {
  target_group_arn = var.target_group_awx
  target_id        = aws_instance.awx_controller.id
  port             = 80
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${var.name}-efs"

  tags = merge("${var.tags}", { Name = "${var.name}-efs" })
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnets_id_a
  security_groups = [var.sg]
}
