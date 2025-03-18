module "fluent_bit_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-fluentbit-sa-role"

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.app_namespace}:fluentbit-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_policy_attachment_to_fluentbit" {
  role       = module.fluent_bit_irsa_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agnet_attachment_to_fluentbit" {
  role       = module.fluent_bit_irsa_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

module "fluentd_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-fluentd-sa-role"

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.fluentd_namespace}:fluentd-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_policy_attachment_to_fluentd" {
  role       = module.fluentd_irsa_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agnet_attachment_to_fluentd" {
  role       = module.fluentd_irsa_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

