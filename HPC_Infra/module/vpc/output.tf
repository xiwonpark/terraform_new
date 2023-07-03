output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

# output "public_subnets_ids" {
#     description = "Public Subnets IDs"  
#     value = aws_subnet.public_sn.*.id
# }

# output "private_subnets_ids" {
#     description = "Private Subnets IDs"
#     value = aws_subnet.private_sn.*.id
# }

output "public_subnets_id_a" {
  value = aws_subnet.public_sn[0].id
}

output "public_subnets_id_c" {
  value = aws_subnet.public_sn[1].id
}

output "private_subnets_id_a" {
  value = aws_subnet.private_sn[0].id
}

output "private_subnets_id_c" {
  value = aws_subnet.private_sn[1].id
}

output "IGW_id" {
  description = "Internet GateWay ID"
  value       = aws_internet_gateway.igw.id
}

output "NGW_id" {
  description = "NAT GateWay ID"
  value       = aws_nat_gateway.nat_gateway.id
}

output "ALB_id" {
  description = "ALB ID"
  value       = aws_alb.alb.id
}

output "sg" {
  description = "Terraform Default SG"
  value       = aws_security_group.default_sg.id
}

output "target_group_vnc" {
  description = "VNC Target Group arn"
  value       = aws_alb_target_group.target_group_vnc.arn
}

output "target_group_awx" {
  description = "AWX Target Group arn"
  value       = aws_alb_target_group.target_group_awx.arn
}