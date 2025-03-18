module "vpc" {
  source = "./vpc"
  prefix = var.prefix
  region = var.region
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./eks"
  cluster_name = var.cluster_name
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  
  depends_on = [ module.vpc ]
}

module "s3" {
  source = "./s3"
  prefix = var.prefix

  depends_on = [ module.eks ]
}

module "ecr" {
  source = "./ecr"
  prefix = var.prefix

  depends_on = [ module.s3 ]
}

module "bastion" {
  source = "./bastion"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  cluster_name = var.cluster_name
  ami_id = data.aws_ami.al2023_ami_amd.id
  public_subnets = module.vpc.public_subnets
  cluster_sg_id = module.eks.cluster_sg_id
  file_bucket_name = module.s3.file_bucket_name
  region = var.region
  account_id = data.aws_caller_identity.current.account_id
  ecr_service_a_name = module.ecr.ecr_service_a_name
  ecr_service_b_name = module.ecr.ecr_service_b_name
  ecr_service_c_name = module.ecr.ecr_service_c_name
  primary_cluster_sg_id = module.eks.primary_cluster_sg_id

  depends_on = [ module.ecr ]
}

module "resources" {
  source = "./resources"
  prefix = var.prefix
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
  app_namespace = var.application_namespace_name
  fluentd_namespace = var.fluentd_namespace_name
  log_group_name = var.log_group_name
  fluentd_daemonset_name = var.fluentd_daemonset_name
  region = var.region
  cluster_name = var.cluster_name
  a_log_stream_name = var.service_a_stream_name
  b_log_stream_name = var.service_b_stream_name
  c_log_stream_name = var.service_c_stream_name
  service_a_deployment_name = var.service_a_deployment_name
  service_b_deployment_name = var.service_b_deployment_name
  service_c_deployment_name = var.service_c_deployment_name
  account_id = data.aws_caller_identity.current.account_id
  ecr_app_a = module.ecr.ecr_service_a_name
  ecr_app_b = module.ecr.ecr_service_b_name
  ecr_app_c = module.ecr.ecr_service_c_name

  depends_on = [ module.bastion ]
}