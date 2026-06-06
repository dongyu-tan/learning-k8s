resource "aws_ecr_repository" "learn-infra-backend" {
  name                 = "learn-infra"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


# TODO: the pull denied is probably due to IAM Policy, need to check this out again
# resource "aws_ecrpublic_repository" "learn-infra-backend" {
#   repository_name = "learn-infra"
# }

output "ecr_url" {
  value       = aws_ecr_repository.learn-infra-backend.repository_url
  description = "learn-infra-backend ecr url"
}
