output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}

output "ecr_url" {
  value       = aws_ecr_repository.learn-infra-backend.repository_url
  description = "learn-infra-backend ecr url"
}
