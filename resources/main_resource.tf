resource "kubernetes_manifest" "app_namespace" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace",
    metadata = {
      name = var.app_namespace
    }
  }
}

resource "kubernetes_service_account" "sa_fluent_bit" {
  
  metadata {
    name = "fluentbit-sa"
    namespace = var.app_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.fluent_bit_irsa_role.iam_role_arn
    }
  }

  depends_on = [ 
    kubernetes_manifest.app_namespace,
    module.fluent_bit_irsa_role
  ]
}

resource "kubernetes_manifest" "fluentd_namespace" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace",
    metadata = {
      name = var.fluentd_namespace
    }
  }

  depends_on = [ kubernetes_service_account.sa_fluent_bit ]
}

resource "kubernetes_service_account" "sa_fluentd" {
  
  metadata {
    name = "fluentd-sa"
    namespace = var.fluentd_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.fluentd_irsa_role.iam_role_arn
    }
  }

  depends_on = [ 
    kubernetes_manifest.fluentd_namespace,
    module.fluentd_irsa_role
  ]
}

resource "kubernetes_manifest" "fluentd_role" {
  for_each = fileset("${path.module}/manifest", "fluentd_role_clusterrole.yaml")

  manifest = yamldecode(
    file("${path.module}/manifest/${each.value}")
  )

  depends_on = [
    kubernetes_service_account.sa_fluentd
  ]
}

resource "kubernetes_manifest" "fluentd_role_binding" {
  for_each = fileset("${path.module}/manifest", "fluentd_role_clusterrolebinding.yaml")

  manifest = yamldecode(
    replace(
      file("${path.module}/manifest/${each.value}"),
      "$(FLUENTD_NAMESPACE)", var.fluentd_namespace
    )
  )

  depends_on = [
    kubernetes_manifest.fluentd_role
  ]
}

resource "kubernetes_manifest" "fluentd_cm" {
  for_each = fileset("${path.module}/manifest", "fluentd_cm.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                file("${path.module}/manifest/${each.value}"),
                "$(FLUENTD_NAMESPACE)", var.fluentd_namespace),
                "$(AWS_REGION)", var.region),
                "$(CLUSTER_NAME)", var.cluster_name),
                "$(LOG_GROUP_NAME)", var.log_group_name),
                "$(A_LOG_STREAM_NAME)", var.a_log_stream_name),
                "$(B_LOG_STREAM_NAME)", var.b_log_stream_name),
                "$(C_LOG_STREAM_NAME)", var.c_log_stream_name
    )
  )

  depends_on = [
    kubernetes_manifest.fluentd_role_binding
  ]
}

resource "kubernetes_manifest" "fluentd_daemonset" {
  for_each = fileset("${path.module}/manifest", "fluentd_daemonset.yaml")

  manifest = yamldecode(
    replace(
      replace(
        file("${path.module}/manifest/${each.value}"),
        "$(FLUENTD_NAMESPACE)", var.fluentd_namespace),
        "$(FLUENTD_DAEMONSET_NAME)", var.fluentd_daemonset_name
    )
  )

  depends_on = [
    kubernetes_manifest.fluentd_cm
  ]
}

resource "kubernetes_manifest" "fluentd_service" {
  for_each = fileset("${path.module}/manifest", "fluentd_svc.yaml")

  manifest = yamldecode(
    replace(
      file("${path.module}/manifest/${each.value}"),
      "$(FLUENTD_NAMESPACE)", var.fluentd_namespace
    )
  )

  depends_on = [
    kubernetes_manifest.fluentd_daemonset
  ]
}

resource "kubernetes_manifest" "fluent_bit_role" {
  for_each = fileset("${path.module}/manifest", "app_clusterrole.yaml")

  manifest = yamldecode(
    file("${path.module}/manifest/${each.value}")
  )

  depends_on = [
    kubernetes_manifest.fluentd_service
  ]
}

resource "kubernetes_manifest" "fluent_bit_role_binding" {
  for_each = fileset("${path.module}/manifest", "app_clusterrolebinding.yaml")

  manifest = yamldecode(
    replace(
    file("${path.module}/manifest/${each.value}"),
    "$(APP_NAMESPACE)", var.app_namespace
    )
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_role
  ]
}

resource "kubernetes_manifest" "service_a" {
  for_each = fileset("${path.module}/manifest", "service_a_*.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          replace(
            replace(
          file("${path.module}/manifest/${each.value}"),
          "$(APP_NAMESPACE)", var.app_namespace),
          "$(SERVICE_A_DEPLOYMENT_NAME)", var.service_a_deployment_name),
          "$(AWS_REGION)", var.region),
          "$(ACCOUNT_ID)", var.account_id),
          "$(ECR_APP_A)", var.ecr_app_a
    )
  )

  depends_on = [
    kubernetes_manifest.fluent_bit_role_binding
  ]
}

resource "kubernetes_manifest" "service_b" {
  for_each = fileset("${path.module}/manifest", "service_b_*.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          replace(
            replace(
          file("${path.module}/manifest/${each.value}"),
          "$(APP_NAMESPACE)", var.app_namespace),
          "$(SERVICE_B_DEPLOYMENT_NAME)", var.service_b_deployment_name),
          "$(AWS_REGION)", var.region),
          "$(ACCOUNT_ID)", var.account_id),
          "$(ECR_APP_B)", var.ecr_app_b
    )
  )

  depends_on = [
    kubernetes_manifest.service_a
  ]
}

resource "kubernetes_manifest" "service_c" {
  for_each = fileset("${path.module}/manifest", "service_c_*.yaml")

 manifest = yamldecode(
    replace(
      replace(
        replace(
          replace(
            replace(
          file("${path.module}/manifest/${each.value}"),
          "$(APP_NAMESPACE)", var.app_namespace),
          "$(SERVICE_C_DEPLOYMENT_NAME)", var.service_c_deployment_name),
          "$(AWS_REGION)", var.region),
          "$(ACCOUNT_ID)", var.account_id),
          "$(ECR_APP_C)", var.ecr_app_c
    )
  )

  depends_on = [
    kubernetes_manifest.service_b
  ]
}