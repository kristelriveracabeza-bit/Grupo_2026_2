
# VARIABLES GENERALES Y BÁSIGAS DEL PROYECTO


variable "project_name" {
  description = "Nombre del proyecto para identificar de forma unívoca los recursos"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "El nombre del proyecto debe contener solo letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno de ejecución actual (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno de ejecución debe ser dev, staging o prod."
  }
}

variable "additional_tags" {
  description = "Tags y metadatos comunes para aplicar a todos los recursos de seguridad"
  type        = map(string)
  default     = {}
}


# VARIABLES PARA INYECCIÓN DE ARNs DE RECURSOS AWS (POLÍCULAS IAM)


variable "sqs_queue_arn" {
  description = "ARN de la cola SQS corporativa para adjuntar permisos de Lambda y ECS"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del tema SNS para permitir flujos de publicación desde Lambda y ECS"
  type        = string
  default     = ""
}

variable "secrets_manager_arn" {
  description = "ARN del secreto en AWS Secrets Manager para descifrado de credenciales"
  type        = string
  default     = ""
}

variable "dynamodb_table_arns" {
  description = "Lista exhaustiva de ARNs de las tablas DynamoDB del proyecto"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3 destinado al almacenamiento interno de datos"
  type        = string
  default     = ""
}

variable "opensearch_arn" {
  description = "ARN del dominio de OpenSearch Service para búsquedas avanzadas"
  type        = string
  default     = ""
}

variable "cloud_map_namespace_arn" {
  description = "ARN del namespace de AWS Cloud Map para descubrimiento privado de servicios"
  type        = string
  default     = ""
}

variable "ecr_repository_arns" {
  description = "Lista de ARNs de los repositorios ECR permitidos para la descarga de imágenes"
  type        = list(string)
  default     = []
}


# VARIABLES PARA CONTROL CONDICIONAL DE POLÍTICAS


variable "enable_vpc_flow_logs" {
  description = "Habilitar la creación y asignación de la política IAM de escritura para VPC Flow Logs"
  type        = bool
  default     = true
}
