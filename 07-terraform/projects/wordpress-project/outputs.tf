output "instance_public_ip" {
  description = "Public IP address of the WordPress server"
  value = aws_instance.wordpress_server.public_ip
  
}

output "wordpress_url" {
  description = "Browser URL to complete WordPress installation"
  value       = "http://${aws_instance.wordpress_server.public_ip}"
  
}