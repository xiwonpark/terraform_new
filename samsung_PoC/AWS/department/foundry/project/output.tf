output "instance_ids_A" {
  description = "A_Project Instance ID"
  value = aws_instance.A_Project.*.id
}

output "instance_ids_test" {
  description = "test_Project Instance ID"
  value = aws_instance.test_Project.*.id
}