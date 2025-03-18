variable "region" {
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  default = "default"
}

variable "prefix" {
  default = "gwangju"
}

variable "cluster_name" {
  default = "gwangju-eks-cluster"
}

variable "application_namespace_name" {
  default = "app"
}

variable "service_a_deployment_name" {
  default = "service-a"
}

variable "service_b_deployment_name" {
  default = "service-b"
}

variable "service_c_deployment_name" {
  default = "service-c"
}

variable "fluentd_namespace_name" {
  default = "fluentd"
}

variable "fluentd_daemonset_name" {
  default = "fluentd"
}

variable "log_group_name" {
  default = "/gwangju/eks/application/logs"
}

variable "service_a_stream_name" {
  default = "service-a-logs"
}

variable "service_b_stream_name" {
  default = "service-b-logs"
}

variable "service_c_stream_name" {
  default = "service-c-logs"
}