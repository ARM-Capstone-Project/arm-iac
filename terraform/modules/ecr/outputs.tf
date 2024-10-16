output "ecr_repository_url" {
  description = "URL of the created ECR repository"
  value       = aws_ecr_repository.arm_fe_ecr_repo.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the created ECR repository"
  value       = aws_ecr_repository.arm_fe_ecr_repo.arn
}

output "ecr_repository_name" {
  description = "Name of the created ECR repository"
  value       = aws_ecr_repository.arm_fe_ecr_repo.name
}
