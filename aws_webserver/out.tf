output "public_ip" {
  value = aws_instance.webserver.public_ip
}

output "url" {
  value = "http://${aws_instance.webserver.public_dns}:80"
}

