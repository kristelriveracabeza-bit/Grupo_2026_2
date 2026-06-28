
# VARIABLES DEL MÓDULO CICD



# VARIABLES OBLIGATORIAS


variable "project_name" {
  description = "Nombre del proyecto para identificar recursos"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "El nombre del proyecto debe contener solo letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno de despliegue: dev, qa, staging, prod"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser: dev, qa, staging o prod."
  }
}

variable "codestar_connection_arn" {
  description = "ARN de la conexión CodeStar para GitHub"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:codestar-connections:", var.codestar_connection_arn))
    error_message = "El ARN debe ser una conexión válida de CodeStar."
  }
}

variable "github_repository_id" {
  description = "ID del repositorio GitHub (formato: usuario/repo)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$", var.github_repository_id))
    error_message = "El ID del repositorio debe tener el formato: usuario/repo"
  }
}


# VARIABLES CON VALORES POR DEFECTO


variable "github_branch_name" {
  description = "Rama de GitHub que activa el pipeline"
  type        = string
  default     = "main"
}

variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS donde se desplegará la aplicación"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "Nombre del servicio ECS que se actualizará"
  type        = string
  default     = ""
}

variable "alb_listener_arn" {
  description = "ARN del listener del ALB para tráfico de producción"
  type        = string
  default     = ""
}

variable "alb_test_listener_arn" {
  description = "ARN del listener de prueba del ALB para Blue/Green (opcional)"
  type        = string
  default     = ""
}

# VARIABLES PARA SONARQUBE

variable "sonarqube_host_url" {
  description = "URL del servidor SonarQube (ej: https://sonarcloud.io)"
  type        = string
  default     = "https://sonarcloud.io"
  
  validation {
    condition     = can(regex("^https?://", var.sonarqube_host_url))
    error_message = "La URL debe comenzar con http:// o https://"
  }
}

variable "sonarqube_project_key" {
  description = "Project key en SonarQube para la aplicación"
  type        = string
  default     = "dermatologia"
}

variable "sonarqube_organization" {
  description = "Organización en SonarQube (requerido para SonarCloud)"
  type        = string
  default     = ""
}


# VARIABLES PARA CHECKOV


variable "enable_checkov" {
  description = "Habilitar escaneo de seguridad con Checkov en el pipeline"
  type        = bool
  default     = true
}

variable "checkov_severity" {
  description = "Severidad mínima para fallar el pipeline (LOW, MEDIUM, HIGH, CRITICAL)"
  type        = string
  default     = "HIGH,CRITICAL"
  
  validation {
    condition     = contains(["LOW", "MEDIUM", "HIGH", "CRITICAL", "HIGH,CRITICAL", "MEDIUM,HIGH,CRITICAL"], var.checkov_severity)
    error_message = "La severidad debe ser: LOW, MEDIUM, HIGH, CRITICAL o combinaciones separadas por coma"
  }
}


# VARIABLES PARA CODEBUILD


variable "codebuild_compute_type" {
  description = "Tipo de computación para CodeBuild"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  
  validation {
    condition     = contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"], var.codebuild_compute_type)
    error_message = "El tipo de computación debe ser: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE o BUILD_GENERAL1_2XLARGE"
  }
}

variable "codebuild_image" {
  description = "Imagen de CodeBuild a utilizar para construcción"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  
  validation {
    condition     = can(regex("^aws/codebuild/", var.codebuild_image))
    error_message = "La imagen debe ser de CodeBuild de AWS"
  }
}

variable "codebuild_privileged_mode" {
  description = "Habilitar modo privilegiado en CodeBuild (requerido para Docker-in-Docker)"
  type        = bool
  default     = false
}


# VARIABLES PARA BUDGETS Y COSTOS


variable "enable_budgets" {
  description = "Habilitar AWS Budgets para control de costos"
  type        = bool
  default     = true
}

variable "budget_limit" {
  description = "Límite de presupuesto mensual en USD"
  type        = number
  default     = 500
  
  validation {
    condition     = var.budget_limit > 0
    error_message = "El límite de presupuesto debe ser mayor a 0."
  }
}

variable "budget_alert_emails" {
  description = "Lista de emails para recibir alertas de presupuesto"
  type        = list(string)
  default     = ["admin@clinica.com"]
  
  validation {
    condition     = length(var.budget_alert_emails) > 0
    error_message = "Debe proporcionar al menos un email para alertas."
  }
}


# VARIABLES PARA LOGS Y MONITOREO


variable "log_retention_days" {
  description = "Días de retención para logs de CloudWatch"
  type        = number
  default     = 30
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Los días de retención deben ser un valor válido para CloudWatch Logs."
  }
}

variable "enable_cloudtrail" {
  description = "Habilitar CloudTrail para auditoría de API"
  type        = bool
  default     = true
}


# VARIABLES PARA NOTIFICACIONES


variable "enable_sns_notifications" {
  description = "Habilitar notificaciones SNS para eventos del pipeline"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN del topic SNS para notificaciones (si enable_sns_notifications = true)"
  type        = string
  default     = ""
}

variable "notification_emails" {
  description = "Emails para notificaciones de despliegue"
  type        = list(string)
  default     = []
  
  validation {
    condition     = alltrue([for email in var.notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "Todos los emails deben tener formato válido."
  }
}


# VARIABLES PARA TAGS


variable "tags" {
  description = "Tags adicionales para aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}


# VARIABLES AVANZADAS (OPCIONALES)


variable "enable_auto_rollback" {
  description = "Habilitar rollback automático en fallo de despliegue"
  type        = bool
  default     = true
}

variable "deployment_timeout_minutes" {
  description = "Tiempo máximo de espera para el despliegue en minutos"
  type        = number
  default     = 30
  
  validation {
    condition     = var.deployment_timeout_minutes >= 5 && var.deployment_timeout_minutes <= 60
    error_message = "El timeout debe estar entre 5 y 60 minutos."
  }
}

variable "enable_manual_approval" {
  description = "Habilitar aprobación manual antes del despliegue en producción"
  type        = bool
  default     = false
}

variable "manual_approval_emails" {
  description = "Emails para aprobación manual (si enable_manual_approval = true)"
  type        = list(string)
  default     = []
  
  validation {
    condition     = alltrue([for email in var.manual_approval_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "Todos los emails deben tener formato válido."
  }
}


# VARIABLES PARA S3


variable "artifacts_bucket_force_destroy" {
  description = "Forzar destrucción del bucket de artefactos (no recomendado en prod)"
  type        = bool
  default     = false
}

variable "cloudtrail_bucket_force_destroy" {
  description = "Forzar destrucción del bucket de CloudTrail (no recomendado en prod)"
  type        = bool
  default     = false
}


# VARIABLES PARA CODEDEPLOY


variable "codedeploy_termination_wait_time" {
  description = "Tiempo de espera en minutos antes de terminar instancias blue en Blue/Green"
  type        = number
  default     = 5
  
  validation {
    condition     = var.codedeploy_termination_wait_time >= 0 && var.codedeploy_termination_wait_time <= 60
    error_message = "El tiempo de espera debe estar entre 0 y 60 minutos."
  }
}

variable "codedeploy_wait_time_minutes" {
  description = "Tiempo de espera en minutos antes de continuar con el despliegue"
  type        = number
  default     = 0
  
  validation {
    condition     = var.codedeploy_wait_time_minutes >= 0 && var.codedeploy_wait_time_minutes <= 60
    error_message = "El tiempo de espera debe estar entre 0 y 60 minutos."
  }
}


# VARIABLES PARA PIPELINE


variable "pipeline_stage_order" {
  description = "Orden de las etapas del pipeline (modificar con precaución)"
  type        = list(string)
  default     = ["Source", "QualityScan", "SecurityScan", "Build", "Deploy"]
  
  validation {
    condition = alltrue([
      contains(var.pipeline_stage_order, "Source"),
      contains(var.pipeline_stage_order, "QualityScan"),
      contains(var.pipeline_stage_order, "SecurityScan"),
      contains(var.pipeline_stage_order, "Build"),
      contains(var.pipeline_stage_order, "Deploy")
    ])
    error_message = "El pipeline debe incluir: Source, QualityScan, SecurityScan, Build, Deploy"
  }
}


# VARIABLES PARA DOCKER


variable "docker_build_context" {
  description = "Contexto de construcción de Docker (ruta al Dockerfile)"
  type        = string
  default     = "."
}

variable "dockerfile_path" {
  description = "Ruta al Dockerfile (relativo al build context)"
  type        = string
  default     = "Dockerfile"
}


# VARIABLES PARA TESTS


variable "run_integration_tests" {
  description = "Ejecutar tests de integración después del despliegue"
  type        = bool
  default     = false
}

variable "test_command" {
  description = "Comando para ejecutar tests (si run_integration_tests = true)"
  type        = string
  default     = "npm test"
}


# VARIABLES PARA SECRETS MANAGER


variable "secrets_rotation_days" {
  description = "Días para rotación automática de secrets (0 = desactivado)"
  type        = number
  default     = 30
  
  validation {
    condition     = var.secrets_rotation_days >= 0 && var.secrets_rotation_days <= 365
    error_message = "La rotación debe ser entre 0 y 365 días."
  }
}

variable "enable_secrets_rotation" {
  description = "Habilitar rotación automática de secrets en Secrets Manager"
  type        = bool
  default     = true
}


# VARIABLES PARA GITHUB TOKEN


variable "enable_github_token" {
  description = "Habilitar secret de GitHub token en Secrets Manager"
  type        = bool
  default     = false
}

variable "github_token" {
  description = "Token de GitHub (si enable_github_token = true)"
  type        = string
  sensitive   = true
  default     = ""
}


# VARIABLES PARA EC2 (si se usa CodeBuild con EC2)


variable "vpc_id" {
  description = "ID de la VPC para recursos de CodeBuild (opcional)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "IDs de subnets para recursos de CodeBuild (opcional)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "IDs de security groups para recursos de CodeBuild (opcional)"
  type        = list(string)
  default     = []
}


# LOCALS PARA DERIVAR VALORES

locals {
  # Generar nombre del proyecto con ambiente
  full_project_name = "${var.project_name}-${var.environment}"
  
  # Tags combinados
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
  
  # Verificar si el entorno es producción
  is_production = var.environment == "prod"
  
  # Verificar si se debe habilitar aprobación manual
  enable_manual_approval_stage = var.enable_manual_approval && var.environment == "prod"
  
  # Bucket de artefactos con nombre único
  artifacts_bucket_name = "${var.project_name}-artifacts-${var.environment}"
  
  # Bucket de CloudTrail con nombre único
  cloudtrail_bucket_name = "${var.project_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}"
  
  # Verificar si Checkov debe ejecutarse
  should_run_checkov = var.enable_checkov && var.environment != "dev"
}