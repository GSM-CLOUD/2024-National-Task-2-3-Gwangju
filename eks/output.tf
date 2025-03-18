output "primary_cluster_sg_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_sg_id" {
  value = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_name" {
  value = module.eks.cluster_name
}