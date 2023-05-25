output "instance_ids_B" {
  description = "B_Project Instance ID"
  value = aws_instance.B_Project.*.id
}

output "instance_ids_C" {
  description = "C_Project Instance ID"
  value = aws_instance.C_Project.*.id
}
