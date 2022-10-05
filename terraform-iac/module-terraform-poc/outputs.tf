# Print out the private ip of the EC2 instance that will be created using this module
output "PrivateIP" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.my-instance.private_ip
}
