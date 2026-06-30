variable "ecr_repositories" {
  description = "Map of ECR repositories to create. The map key is used as the repository name."
  type = map(object({
    force_delete         = optional(bool, false)
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
  }))

  validation {
    condition = alltrue([
      for repository in values(var.ecr_repositories) :
      contains(["MUTABLE", "IMMUTABLE"], repository.image_tag_mutability)
    ])
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "ecr_tags" {
  description = "Tags to apply to ECR repositories."
  type        = map(string)
  default     = {}
}
