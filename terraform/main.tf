module "ecr" {
  source = "./modules/ecr"

  ecr_repo_name = local.ecr_repo_name
}

module "eks" {
  source = "./modules/eks"

  environment = local.environment
}