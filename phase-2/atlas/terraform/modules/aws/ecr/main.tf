resource "aws_ecr_repository" "repository" {
  for_each = var.ecr_repositories

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  tags = merge(var.ecr_tags, {
    Name = each.key
  })
}
