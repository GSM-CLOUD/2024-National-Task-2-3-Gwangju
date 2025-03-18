variable "prefix" {}

variable "eks_oidc_provider_arn" {}

variable "app_namespace" {}

variable "fluentd_namespace" {}

variable "log_group_name" {}

variable "fluentd_daemonset_name" {}

variable "region" {}

variable "cluster_name" {}

variable "a_log_stream_name" {}
  
variable "b_log_stream_name" {}
  
variable "c_log_stream_name" {}

variable "service_a_deployment_name" {}

variable "service_b_deployment_name" {}

variable "service_c_deployment_name" {}

variable "account_id" {}

variable "ecr_app_a" {}

variable "ecr_app_b" {}

variable "ecr_app_c" {}
