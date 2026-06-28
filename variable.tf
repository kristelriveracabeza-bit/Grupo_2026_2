# =============================================================================
# VARIABLES DEL PROYECTO
# =============================================================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "El entorno debe ser: dev, qa o prod."
  }
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags adicionales para todos los recursos"
  type        = map(string)
  default     = {}
}

# =============================================================================
# VARIABLES PARA VPC Y REDES
# =============================================================================

variable "vpc_id" {
  description = "ID de la VPC donde se desplegarán los recursos"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# =============================================================================
# VARIABLES PARA ECS
# =============================================================================

variable "ecr_repository_url" {
  description = "URL del repositorio ECR para la imagen de la aplicación"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN del rol de ejecución de ECS"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN del rol de tarea de ECS"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID del security group del ALB"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "Nombre del servicio ECS"
  type        = string
  default     = ""
}

variable "ecs_task_cpu" {
  description = "CPU para la tarea ECS (en unidades de 1024)"
  type        = string
  default     = "512"
}

variable "ecs_task_memory" {
  description = "Memoria para la tarea ECS (en MB)"
  type        = string
  default     = "1024"
}

variable "ecs_desired_count" {
  description = "Número deseado de instancias"
  type        = number
  default     = 1
}

variable "ecs_min_capacity" {
  description = "Capacidad mínima para auto scaling"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Capacidad máxima para auto scaling"
  type        = number
  default     = 5
}

variable "container_port" {
  description = "Puerto del contenedor"
  type        = number
  default     = 3001
}

variable "image_tag" {
  description = "Tag de la imagen Docker"
  type        = string
  default     = "latest"
}

variable "enable_container_insights" {
  description = "Habilitar Container Insights"
  type        = bool
  default     = true
}

variable "log_level" {
  description = "Nivel de logging para la aplicación"
  type        = string
  default     = "info"
}

variable "enable_lambda" {
  description = "Habilitar la función Lambda en el módulo compute"
  type        = bool
  default     = true
}

# =============================================================================
# VARIABLES PARA LAMBDA
# =============================================================================

variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
  default     = null
}

variable "lambda_role_name" {
  description = "Nombre del rol IAM de Lambda"
  type        = string
  default     = null
}

variable "lambda_role_arn" {
  description = "ARN del rol IAM de Lambda"
  type        = string
  default     = ""
}

variable "lambda_zip_path" {
  description = "Ruta del archivo ZIP de la Lambda"
  type        = string
  default     = "lambda.zip"
}

variable "lambda_handler" {
  description = "Handler de Lambda"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime de Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_memory_size" {
  description = "Memoria de Lambda en MB"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout de Lambda en segundos"
  type        = number
  default     = 60
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS"
  type        = string
  default     = ""
}

variable "sqs_queue_url" {
  description = "URL de la cola SQS"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "ARN del tema SNS"
  type        = string
  default     = ""
}

# =============================================================================
# VARIABLES PARA SECRETS Y COGNITO
# =============================================================================

variable "secret_name" {
  description = "Nombre del secret en Secrets Manager"
  type        = string
  default     = ""
}

variable "secrets_manager_arn" {
  description = "ARN del secret en Secrets Manager"
  type        = string
  default     = ""
}

variable "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  type        = string
  default     = ""
}

variable "cognito_client_id" {
  description = "ID del Client de Cognito"
  type        = string
  default     = ""
}

# =============================================================================
# VARIABLES PARA SNS Y SQS (RECURSOS EXISTENTES)
# =============================================================================

variable "sns_topic_name" {
  description = "Nombre del tema SNS existente"
  type        = string
  default     = ""
}

variable "sqs_queue_name" {
  description = "Nombre de la cola SQS existente"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Nombre del bucket S3 existente"
  type        = string
  default     = ""
}

# =============================================================================
# VARIABLES PARA MICROSERVICIOS
# =============================================================================

variable "appointments_service_name" {
  description = "Nombre del servicio de appointments"
  type        = string
  default     = "appointments"
}

variable "patients_service_name" {
  description = "Nombre del servicio de patients"
  type        = string
  default     = "patients"
}

variable "appointments_endpoint" {
  description = "Endpoint del servicio de appointments"
  type        = string
  default     = ""
}

variable "patients_endpoint" {
  description = "Endpoint del servicio de patients"
  type        = string
  default     = ""
}

# =============================================================================
# VARIABLES PARA MONITOREO
# =============================================================================

variable "log_retention_days" {
  description = "Días de retención para logs de CloudWatch"
  type        = number
  default     = 30
}

variable "sqs_depth_threshold" {
  description = "Umbral de profundidad de SQS para alarmas"
  type        = number
  default     = 10
}

variable "lambda_duration_threshold" {
  description = "Umbral de duración de Lambda en segundos"
  type        = number
  default     = 30
}

# =============================================================================
# VARIABLES PARA BUDGETS
# =============================================================================

variable "create_budget" {
  description = "Crear budget de AWS"
  type        = bool
  default     = false
}

variable "budget_limit_amount" {
  description = "Monto límite del budget"
  type        = string
  default     = "100"
}

variable "budget_threshold_first" {
  description = "Primer umbral del budget"
  type        = number
  default     = 80
}

variable "budget_threshold_second" {
  description = "Segundo umbral del budget"
  type        = number
  default     = 95
}

variable "budget_alert_emails" {
  description = "Emails para alertas de budget"
  type        = list(string)
  default     = []
}

# =============================================================================
# VARIABLES PARA DYNAMODB
# =============================================================================

variable "dynamodb_table_arns" {
  description = "ARNs de las tablas DynamoDB"
  type        = list(string)
  default     = []
}

# =============================================================================
# VARIABLES PARA ECR
# =============================================================================

variable "ecr_repository_arns" {
  description = "ARNs de los repositorios ECR"
  type        = list(string)
  default     = []
}

# =============================================================================
# VARIABLES PARA CICD
# =============================================================================

variable "enable_cicd" {
  description = "Habilitar módulo CI/CD"
  type        = bool
  default     = false
}

variable "codestar_connection_arn" {
  description = "ARN de la conexión de CodeStar"
  type        = string
  default     = ""
}

variable "github_repository_id" {
  description = "ID del repositorio de GitHub"
  type        = string
  default     = ""
}

variable "github_branch_name" {
  description = "Rama de GitHub"
  type        = string
  default     = "main"
}

variable "alb_listener_arn" {
  description = "ARN del listener del ALB"
  type        = string
  default     = ""
}

variable "alb_test_listener_arn" {
  description = "ARN del listener de prueba del ALB"
  type        = string
  default     = ""
}

variable "sonarqube_host_url" {
  description = "URL de SonarQube"
  type        = string
  default     = ""
}

variable "sonarqube_project_key" {
  description = "Project key de SonarQube"
  type        = string
  default     = ""
}

variable "sonarqube_organization" {
  description = "Organización de SonarQube"
  type        = string
  default     = ""
}

variable "codebuild_compute_type" {
  description = "Tipo de cómputo de CodeBuild"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  description = "Imagen de CodeBuild"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "codebuild_privileged_mode" {
  description = "Modo privilegiado de CodeBuild"
  type        = bool
  default     = true
}

variable "enable_checkov" {
  description = "Habilitar Checkov"
  type        = bool
  default     = true
}

variable "checkov_severity" {
  description = "Severidad de Checkov"
  type        = string
  default     = "LOW"
}

variable "enable_budgets" {
  description = "Habilitar budgets"
  type        = bool
  default     = false
}

variable "budget_limit" {
  description = "Límite del budget"
  type        = string
  default     = "100"
}

variable "enable_cloudtrail" {
  description = "Habilitar CloudTrail"
  type        = bool
  default     = false
}

variable "enable_auto_rollback" {
  description = "Habilitar auto rollback"
  type        = bool
  default     = true
}

variable "codedeploy_termination_wait_time" {
  description = "Tiempo de espera de termination en CodeDeploy"
  type        = number
  default     = 30
}

variable "codedeploy_wait_time_minutes" {
  description = "Tiempo de espera en minutos para CodeDeploy"
  type        = number
  default     = 5
}
