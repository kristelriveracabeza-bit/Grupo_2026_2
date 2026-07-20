# VARIABLES DEL MÓDULO COMPUTE


# VARIABLES OBLIGATORIAS


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

variable "vpc_id" {
  description = "ID de la VPC"
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


# VARIABLES PARA ECS


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

variable "ecr_repository_url" {
  description = "URL del repositorio ECR"
  type        = string
}

variable "image_tag" {
  description = "Tag de la imagen Docker"
  type        = string
  default     = "latest"
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

variable "secrets_manager_arn" {
  description = "ARN del secret en Secrets Manager"
  type        = string
  default     = ""
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

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}


# VARIABLES PARA LAMBDA


variable "enable_lambda" {
  description = "Habilitar la función Lambda"
  type        = bool
  default     = true
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
  default     = null
}

variable "lambda_role_arn" {
  description = "ARN del rol IAM de Lambda"
  type        = string
  default     = ""
}

variable "lambda_role_name" {
  description = "Nombre del rol IAM de Lambda"
  type        = string
  default     = null
}

variable "lambda_runtime" {
  description = "Runtime de Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_handler" {
  description = "Handler de Lambda"
  type        = string
  default     = "lambda_function.lambda_handler"
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

variable "lambda_zip_path" {
  description = "Ruta del archivo ZIP de la Lambda"
  type        = string
  default     = "lambda.zip"
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS para Lambda"
  type        = string
  default     = ""
}

variable "sqs_queue_url" {
  description = "URL de la cola SQS para Lambda"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "ARN del tema SNS para Lambda"
  type        = string
  default     = ""
}

variable "secret_name" {
  description = "Nombre del secret en Secrets Manager"
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


# VARIABLES PARA LOGS


variable "log_retention_days" {
  description = "Días de retención para logs de CloudWatch"
  type        = number
  default     = 30
}


# VARIABLES PARA TAGS


variable "tags" {
  description = "Tags adicionales para todos los recursos"
  type        = map(string)
  default     = {}
}
