output "public_ip" {
  value = aws_eip.static_ip.public_ip
}

output "static_ip" {
  value       = aws_eip.static_ip.public_ip
  description = "The public IP of the web server"
}