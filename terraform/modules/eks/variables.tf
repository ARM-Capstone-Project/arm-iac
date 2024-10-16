variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default CIDR range of the VPC"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  default     = "latest"
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "The environment to create resources in"
  type        = string
}
