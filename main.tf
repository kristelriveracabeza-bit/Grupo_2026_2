# Configuracion de Terraform
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Proveedor
provider "aws" {
  region = var.aws_region
}

# =============================================================================
# MÓDULO: EVENTOS (S3, SNS, SQS)
# =============================================================================
module "events" {
  source = "./modules/events"

  # RECURSOS EXISTENTES
  existing_sns_topic_name   = var.sns_topic_name
  existing_sqs_queue_name   = var.sqs_queue_name
  existing_s3_bucket_name   = var.s3_bucket_name
  lambda_function_name      = var.lambda_function_name
  lambda_role_name          = var.lambda_role_name != null ? var.lambda_role_name : "${var.project_name}-lambda-role-${var.environment}"
  
  # CONFIGURACIÓN - USAR RECURSOS EXISTENTES
  create_new_sns_topic      = false
  create_new_sqs_queue      = false
  create_new_s3_bucket      = false
  
  # CONFIGURACIÓN DE LAMBDA (para el módulo events)
  lambda_zip_path           = var.lambda_zip_path
  lambda_handler            = var.lambda_handler
  lambda_runtime            = var.lambda_runtime
  lambda_timeout            = var.lambda_timeout
  lambda_memory_size        = var.lambda_memory_size
  
  # SECRETS MANAGER
  secret_name               = var.secret_name
  
  # COGNITO
  cognito_user_pool_id      = var.cognito_user_pool_id
  cognito_client_id         = var.cognito_client_id
  
  # ECS MICROSERVICES
  ecs_cluster_name          = var.ecs_cluster_name
  appointments_service_name = var.appointments_service_name
  patients_service_name     = var.patients_service_name
  appointments_endpoint     = var.appointments_endpoint
  patients_endpoint         = var.patients_endpoint
  
  # MONITOREO
  log_retention_days        = var.log_retention_days
  sqs_depth_threshold       = var.sqs_depth_threshold
  lambda_duration_threshold = var.lambda_duration_threshold
  
  # BUDGETS
  create_budget             = var.create_budget
  budget_limit_amount       = var.budget_limit_amount
  budget_threshold_first    = var.budget_threshold_first
  budget_threshold_second   = var.budget_threshold_second
  budget_alert_emails       = var.budget_alert_emails
  
  # TAGS
  tags = var.tags
}

# =============================================================================
# MÓDULO: SEGURIDAD (IAM ROLES) - CORREGIDO
# =============================================================================
module "security" {
  source = "./modules/security"

  project_name   = var.project_name
  environment    = var.environment
  
  # Recursos para políticas
  sqs_queue_arn         = module.events.sqs_queue_arn
  sns_topic_arn         = module.events.sns_topic_arn
  secrets_manager_arn   = var.secrets_manager_arn != "" ? var.secrets_manager_arn : null
  s3_bucket_arn         = module.events.s3_bucket_arn
  dynamodb_table_arns   = var.dynamodb_table_arns
  
  # ECR (opcional)
  ecr_repository_arns   = var.ecr_repository_arns
  
  # Tags
  tags = var.tags
}

module "compute" {
  source = "./modules/compute"

  # OBLIGATORIAS
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = var.vpc_id
  private_subnet_ids     = var.private_subnet_ids
  public_subnet_ids      = var.public_subnet_ids
  ecr_repository_url     = var.ecr_repository_url
  ecs_execution_role_arn = var.ecs_execution_role_arn
  ecs_task_role_arn      = var.ecs_task_role_arn
  alb_security_group_id  = var.alb_security_group_id
  
  # OPCIONALES PERO RECOMENDADAS
  sqs_queue_arn          = module.events.sqs_queue_arn
  sqs_queue_url          = module.events.sqs_queue_url
  sns_topic_arn          = module.events.sns_topic_arn
  lambda_role_arn        = module.security.lambda_role_arn
  
  # NUEVAS VARIABLES (ya las tienes)
  secret_name            = var.secret_name
  cognito_user_pool_id   = var.cognito_user_pool_id
  cognito_client_id      = var.cognito_client_id
  
  # Tags
  tags = var.tags
}

# =============================================================================
# MÓDULO: CICD (OPCIONAL)
# =============================================================================
module "cicd" {
  count  = var.enable_cicd ? 1 : 0
  source = "./modules/cicd"

  # Información del proyecto
  project_name            = var.project_name
  environment             = var.environment
  
  # GitHub/Codestar
  codestar_connection_arn = var.codestar_connection_arn
  github_repository_id    = var.github_repository_id
  github_branch_name      = var.github_branch_name
  
  # ECS (requerido por el módulo CICD)
  ecs_cluster_name        = var.ecs_cluster_name
  ecs_service_name        = var.ecs_service_name
  alb_listener_arn        = var.alb_listener_arn
  alb_test_listener_arn   = var.alb_test_listener_arn
  
  # SonarQube
  sonarqube_host_url      = var.sonarqube_host_url
  sonarqube_project_key   = var.sonarqube_project_key
  sonarqube_organization  = var.sonarqube_organization
  
  # CodeBuild
  codebuild_compute_type  = var.codebuild_compute_type
  codebuild_image         = var.codebuild_image
  codebuild_privileged_mode = var.codebuild_privileged_mode
  
  # Checkov
  enable_checkov          = var.enable_checkov
  checkov_severity        = var.checkov_severity
  
  # Budgets
  enable_budgets          = var.enable_budgets
  budget_limit            = var.budget_limit
  budget_alert_emails     = var.budget_alert_emails
  
  # Logs
  log_retention_days      = var.log_retention_days
  
  # CloudTrail
  enable_cloudtrail       = var.enable_cloudtrail
  
  # Auto Rollback
  enable_auto_rollback    = var.enable_auto_rollback
  
  # CodeDeploy
  codedeploy_termination_wait_time = var.codedeploy_termination_wait_time
  codedeploy_wait_time_minutes     = var.codedeploy_wait_time_minutes
  
  # Tags
  tags = var.tags
}
