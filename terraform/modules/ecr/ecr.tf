resource "aws_ecr_repository" "arm_fe_ecr_repo" {
  name = var.ecr_repo_name

  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_lifecycle_policy" "arm_fe_ecr_repo" {
  repository = aws_ecr_repository.arm_fe_ecr_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images by count",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}