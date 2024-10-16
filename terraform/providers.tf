terraform {
  required_version = ">=1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}

provider "aws" {
  region = local.aws_region

  // These are required to connect Terraform and AWS from local machine
  // Not required when using Jenkins server
  
  // shared_credentials_files = ["/Users/macbook/.aws/config"]
  // profile                  = "default"
}