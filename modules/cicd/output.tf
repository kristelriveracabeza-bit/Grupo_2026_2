
# OUTPUTS DEL MÓDULO CICD


# PIPELINE OUTPUTS


output "codepipeline_name" {
  description = "Nombre del pipeline de CI/CD"
  value       = aws_codepipeline.this.name
}

output "codepipeline_arn" {
  description = "ARN del pipeline de CI/CD"
  value       = aws_codepipeline.this.arn
}

output "codepipeline_stages" {
  description = "Etapas del pipeline"
  value = [
    "Source",
    "QualityScan",
    "SecurityScan",
    "Build",
    "Deploy"
  ]
}

output "codepipeline_version" {
  description = "Versión del pipeline"
  value       = aws_codepipeline.this.version
}


# CODEBUILD OUTPUTS


output "codebuild_project_name" {
  description = "Nombre del proyecto CodeBuild para construcción de imágenes"
  value       = aws_codebuild_project.app_build.name
}

output "codebuild_project_arn" {
  description = "ARN del proyecto CodeBuild para construcción"
  value       = aws_codebuild_project.app_build.arn
}

output "codebuild_project_url" {
  description = "URL del proyecto CodeBuild"
  value       = "https://console.aws.amazon.com/codesuite/codebuild/projects/${aws_codebuild_project.app_build.name}/history?region=${data.aws_region.current.name}"
}

output "codebuild_sonarqube_name" {
  description = "Nombre del proyecto CodeBuild para SonarQube"
  value       = aws_codebuild_project.sonarqube_scan.name
}

output "codebuild_sonarqube_arn" {
  description = "ARN del proyecto CodeBuild para SonarQube"
  value       = aws_codebuild_project.sonarqube_scan.arn
}

output "codebuild_sonarqube_url" {
  description = "URL del proyecto CodeBuild para SonarQube"
  value       = "https://console.aws.amazon.com/codesuite/codebuild/projects/${aws_codebuild_project.sonarqube_scan.name}/history?region=${data.aws_region.current.name}"
}

output "codebuild_checkov_name" {
  description = "Nombre del proyecto CodeBuild para Checkov"
  value       = var.enable_checkov ? aws_codebuild_project.checkov_scan[0].name : null
}

output "codebuild_checkov_arn" {
  description = "ARN del proyecto CodeBuild para Checkov"
  value       = var.enable_checkov ? aws_codebuild_project.checkov_scan[0].arn : null
}

output "codebuild_checkov_url" {
  description = "URL del proyecto CodeBuild para Checkov"
  value       = var.enable_checkov ? "https://console.aws.amazon.com/codesuite/codebuild/projects/${aws_codebuild_project.checkov_scan[0].name}/history?region=${data.aws_region.current.name}" : null
}

output "codebuild_checkov_enabled" {
  description = "Indica si Checkov está habilitado"
  value       = var.enable_checkov
}


# CODEDEPLOY OUTPUTS


output "codedeploy_app_name" {
  description = "Nombre de la aplicación CodeDeploy para ECS"
  value       = aws_codedeploy_app.ecs.name
}

output "codedeploy_app_arn" {
  description = "ARN de la aplicación CodeDeploy"
  value       = aws_codedeploy_app.ecs.arn
}

output "codedeploy_deployment_group_name" {
  description = "Nombre del grupo de despliegue CodeDeploy"
  value       = aws_codedeploy_deployment_group.ecs.deployment_group_name
}

output "codedeploy_deployment_group_arn" {
  description = "ARN del grupo de despliegue CodeDeploy"
  value       = aws_codedeploy_deployment_group.ecs.arn
}

output "codedeploy_deployment_config" {
  description = "Configuración de despliegue utilizada"
  value       = "CodeDeployDefault.ECSAllAtOnce"
}

output "codedeploy_auto_rollback_enabled" {
  description = "Indica si el rollback automático está habilitado"
  value       = var.enable_auto_rollback
}

output "codedeploy_url" {
  description = "URL para acceder a CodeDeploy en AWS Console"
  value       = "https://console.aws.amazon.com/codesuite/codedeploy/applications/${aws_codedeploy_app.ecs.name}/deployment-groups/${aws_codedeploy_deployment_group.ecs.deployment_group_name}?region=${data.aws_region.current.name}"
}


# S3 OUTPUTS


output "artifacts_bucket_name" {
  description = "Nombre del bucket S3 para artefactos del pipeline"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN del bucket S3 para artefactos"
  value       = aws_s3_bucket.artifacts.arn
}

output "artifacts_bucket_domain_name" {
  description = "Nombre de dominio del bucket S3 para artefactos"
  value       = aws_s3_bucket.artifacts.bucket_domain_name
}

output "artifacts_bucket_regional_domain_name" {
  description = "Nombre de dominio regional del bucket S3 para artefactos"
  value       = aws_s3_bucket.artifacts.bucket_regional_domain_name
}

output "cloudtrail_bucket_name" {
  description = "Nombre del bucket S3 para logs de CloudTrail"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_bucket_arn" {
  description = "ARN del bucket S3 para logs de CloudTrail"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}


# CLOUDTRAIL OUTPUTS


output "cloudtrail_name" {
  description = "Nombre del trail de CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.this[0].name : null
}

output "cloudtrail_arn" {
  description = "ARN del trail de CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.this[0].arn : null
}

output "cloudtrail_bucket" {
  description = "Bucket donde se almacenan los logs de CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.this[0].s3_bucket_name : null
}

output "cloudtrail_enabled" {
  description = "Indica si CloudTrail está habilitado"
  value       = var.enable_cloudtrail
}

output "cloudtrail_url" {
  description = "URL para acceder a CloudTrail en AWS Console"
  value       = "https://console.aws.amazon.com/cloudtrail/home?region=${data.aws_region.current.name}#/events"
}


# SECRETS MANAGER OUTPUTS


output "secrets_manager_sonarqube_secret_name" {
  description = "Nombre del secret en Secrets Manager para SonarQube"
  value       = aws_secretsmanager_secret.sonarqube_token.name
}

output "secrets_manager_sonarqube_secret_arn" {
  description = "ARN del secret en Secrets Manager para SonarQube"
  value       = aws_secretsmanager_secret.sonarqube_token.arn
}

output "secrets_manager_github_secret_name" {
  description = "Nombre del secret en Secrets Manager para GitHub"
  value       = var.enable_github_token ? aws_secretsmanager_secret.github_token[0].name : null
}

output "secrets_manager_github_secret_arn" {
  description = "ARN del secret en Secrets Manager para GitHub"
  value       = var.enable_github_token ? aws_secretsmanager_secret.github_token[0].arn : null
}

output "secrets_manager_url" {
  description = "URL para acceder a Secrets Manager en AWS Console"
  value       = "https://console.aws.amazon.com/secretsmanager/home?region=${data.aws_region.current.name}#/secret?name=${aws_secretsmanager_secret.sonarqube_token.name}"
}


# IAM OUTPUTS


output "pipeline_role_name" {
  description = "Nombre del rol IAM del pipeline"
  value       = aws_iam_role.pipeline_role.name
}

output "pipeline_role_arn" {
  description = "ARN del rol IAM del pipeline"
  value       = aws_iam_role.pipeline_role.arn
}

output "pipeline_role_id" {
  description = "ID del rol IAM del pipeline"
  value       = aws_iam_role.pipeline_role.id
}

# KMS OUTPUTS


output "kms_key_id" {
  description = "ID de la clave KMS para CodeBuild"
  value       = aws_kms_key.codebuild_cmk.key_id
}

output "kms_key_arn" {
  description = "ARN de la clave KMS para CodeBuild"
  value       = aws_kms_key.codebuild_cmk.arn
}

output "kms_key_alias" {
  description = "Alias de la clave KMS para CodeBuild"
  value       = aws_kms_alias.codebuild_cmk_alias.name
}


# BUDGETS OUTPUTS


output "budget_name" {
  description = "Nombre del presupuesto configurado"
  value       = var.enable_budgets ? aws_budgets_budget.monthly[0].name : null
}

output "budget_limit" {
  description = "Límite del presupuesto en USD"
  value       = var.budget_limit
}

output "budget_notification_emails" {
  description = "Emails configurados para alertas de presupuesto"
  value       = var.budget_alert_emails
}

output "budgets_enabled" {
  description = "Indica si los budgets están habilitados"
  value       = var.enable_budgets
}


# CLOUDWATCH LOGS OUTPUTS


output "cloudwatch_log_groups" {
  description = "Nombres de los grupos de logs de CloudWatch para CodeBuild"
  value = {
    build       = aws_cloudwatch_log_group.codebuild_build.name
    sonarqube   = aws_cloudwatch_log_group.codebuild_sonarqube.name
    checkov     = var.enable_checkov ? aws_cloudwatch_log_group.codebuild_checkov[0].name : null
  }
}

output "cloudwatch_log_group_arns" {
  description = "ARNs de los grupos de logs de CloudWatch"
  value = {
    build       = aws_cloudwatch_log_group.codebuild_build.arn
    sonarqube   = aws_cloudwatch_log_group.codebuild_sonarqube.arn
    checkov     = var.enable_checkov ? aws_cloudwatch_log_group.codebuild_checkov[0].arn : null
  }
}

output "log_retention_days" {
  description = "Días de retención configurados para logs"
  value       = var.log_retention_days
}


# ENVIRONMENT OUTPUTS


output "environment" {
  description = "Entorno del módulo"
  value       = var.environment
}

output "project_name" {
  description = "Nombre del proyecto"
  value       = var.project_name
}

output "full_project_name" {
  description = "Nombre completo del proyecto con entorno"
  value       = "${var.project_name}-${var.environment}"
}

output "is_production" {
  description = "Indica si el entorno es producción"
  value       = var.environment == "prod"
}

output "region" {
  description = "Región de AWS"
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "ID de la cuenta de AWS"
  value       = data.aws_caller_identity.current.account_id
}


# DNS AND ENDPOINTS


output "alb_listener_arn" {
  description = "ARN del listener del ALB usado para despliegues"
  value       = var.alb_listener_arn
}

output "alb_test_listener_arn" {
  description = "ARN del listener de prueba del ALB"
  value       = var.alb_test_listener_arn
}


# ECS OUTPUTS


output "ecs_cluster_name" {
  description = "Nombre del cluster ECS donde se despliega"
  value       = var.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS que se despliega"
  value       = var.ecs_service_name
}


# GITHUB OUTPUTS


output "github_repository" {
  description = "Repositorio GitHub configurado"
  value       = var.github_repository_id
}

output "github_branch" {
  description = "Rama de GitHub configurada"
  value       = var.github_branch_name
}


# SONARQUBE OUTPUTS


output "sonarqube_host_url" {
  description = "URL del servidor SonarQube"
  value       = var.sonarqube_host_url
}

output "sonarqube_project_key" {
  description = "Project key en SonarQube"
  value       = var.sonarqube_project_key
}

output "sonarqube_organization" {
  description = "Organización en SonarQube"
  value       = var.sonarqube_organization
}


# CHECKOV OUTPUTS


output "checkov_severity" {
  description = "Severidad configurada para Checkov"
  value       = var.checkov_severity
}


# PIPELINE STATUS AND URLS


output "pipeline_url" {
  description = "URL para acceder al pipeline en AWS Console"
  value       = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.this.name}/view?region=${data.aws_region.current.name}"
}

output "codebuild_url" {
  description = "URL para acceder a CodeBuild en AWS Console"
  value       = "https://console.aws.amazon.com/codesuite/codebuild/projects/${aws_codebuild_project.app_build.name}/history?region=${data.aws_region.current.name}"
}

output "codedeploy_url" {
  description = "URL para acceder a CodeDeploy en AWS Console"
  value       = "https://console.aws.amazon.com/codesuite/codedeploy/applications/${aws_codedeploy_app.ecs.name}/deployment-groups/${aws_codedeploy_deployment_group.ecs.deployment_group_name}?region=${data.aws_region.current.name}"
}

output "cloudtrail_url" {
  description = "URL para acceder a CloudTrail en AWS Console"
  value       = "https://console.aws.amazon.com/cloudtrail/home?region=${data.aws_region.current.name}#/events"
}

output "secrets_manager_url" {
  description = "URL para acceder a Secrets Manager en AWS Console"
  value       = "https://console.aws.amazon.com/secretsmanager/home?region=${data.aws_region.current.name}#/secret?name=${aws_secretsmanager_secret.sonarqube_token.name}"
}

output "s3_artifacts_url" {
  description = "URL para acceder al bucket de artefactos en AWS Console"
  value       = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.artifacts.bucket}?region=${data.aws_region.current.name}"
}


# TAGS OUTPUTS


output "common_tags" {
  description = "Tags comunes aplicados a los recursos"
  value = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

output "all_tags" {
  description = "Todos los tags aplicados (incluyendo los personalizados)"
  value       = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}


# CONFIGURATION SUMMARY


output "configuration_summary" {
  description = "Resumen de la configuración del módulo CICD"
  value = {
    project_name          = var.project_name
    environment           = var.environment
    github_repository     = var.github_repository_id
    github_branch         = var.github_branch_name
    ecs_cluster           = var.ecs_cluster_name
    ecs_service           = var.ecs_service_name
    sonarqube_enabled     = var.sonarqube_host_url != ""
    checkov_enabled       = var.enable_checkov
    budgets_enabled       = var.enable_budgets
    budget_limit          = var.budget_limit
    cloudtrail_enabled    = var.enable_cloudtrail
    auto_rollback_enabled = var.enable_auto_rollback
    log_retention_days    = var.log_retention_days
    secrets_rotation_days = var.secrets_rotation_days
    is_production         = var.environment == "prod"
  }
}


# BUILD INFORMATION


output "codebuild_compute_type" {
  description = "Tipo de computación usado en CodeBuild"
  value       = var.codebuild_compute_type
}

output "codebuild_image" {
  description = "Imagen usada en CodeBuild"
  value       = var.codebuild_image
}

output "codebuild_privileged_mode" {
  description = "Indica si el modo privilegiado está habilitado"
  value       = var.codebuild_privileged_mode
}


# DEPLOYMENT CONFIGURATION


output "deployment_timeout_minutes" {
  description = "Timeout de despliegue en minutos"
  value       = var.deployment_timeout_minutes
}

output "codedeploy_termination_wait_time" {
  description = "Tiempo de espera antes de terminar instancias blue"
  value       = var.codedeploy_termination_wait_time
}

output "codedeploy_wait_time_minutes" {
  description = "Tiempo de espera antes de continuar despliegue"
  value       = var.codedeploy_wait_time_minutes
}


# MANUAL APPROVAL OUTPUTS


output "manual_approval_enabled" {
  description = "Indica si la aprobación manual está habilitada"
  value       = var.enable_manual_approval
}

output "manual_approval_emails" {
  description = "Emails para aprobación manual"
  value       = var.manual_approval_emails
}

# SECURITY OUTPUTS


output "secrets_rotation_enabled" {
  description = "Indica si la rotación de secrets está habilitada"
  value       = var.enable_secrets_rotation
}

output "secrets_rotation_days" {
  description = "Días de rotación de secrets"
  value       = var.secrets_rotation_days
}


# UTILITY OUTPUTS (para scripting)


output "codepipeline_execution_command" {
  description = "Comando para ejecutar el pipeline manualmente"
  value       = "aws codepipeline start-pipeline-execution --name ${aws_codepipeline.this.name}"
}

output "codebuild_start_command" {
  description = "Comando para iniciar un build manualmente"
  value       = "aws codebuild start-build --project-name ${aws_codebuild_project.app_build.name}"
}

output "deploy_rollback_command" {
  description = "Comando para hacer rollback manual"
  value       = "aws deploy stop-deployment --deployment-id <DEPLOYMENT_ID>"
}