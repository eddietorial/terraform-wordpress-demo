output "instance_id" {
  description = "ARN of the WordPress EC2 instance"
  value       = aws_instance.wordpress.arn
}

output "instance_public_ip" {
  description = "Public IP of the WordPress instance. Visit http://<ip> in a browser or connect via ssh ubuntu@<ip>"
  value       = aws_instance.wordpress.public_ip
}

