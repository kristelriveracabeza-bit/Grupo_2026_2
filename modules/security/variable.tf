
# VARIABLES BÁSICAS


variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

# VARIABLES PARA RECURSOS AWS


variable "sqs_queue_arn" {
  description = "ARN de la cola SQS para permisos de Lambda y ECS"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del tema SNS para permisos de Lambda y ECS"
  type        = string
  default     = ""
}

variable "secrets_manager_arn" {
  description = "ARN del secret en Secrets Manager"
  type        = string
  default     = ""
}

variable "dynamodb_table_arns" {
  description = "Lista de ARNs de las tablas DynamoDB"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
  default     = ""
}

variable "opensearch_arn" {
  description = "ARN del dominio OpenSearch"
  type        = string
  default     = ""
}

variable "cloud_map_namespace_arn" {
  description = "ARN del namespace de Cloud Map"
  type        = string
  default     = ""
}


# VARIABLES PARA POLÍTICAS ADICIONALES

variable "create_vpc_flow_logs_policy" {
  description = "Crear política para VPC Flow Logs"
  type        = bool
  default     = false
}
variable "ecr_repository_arns" {
  description = "Lista de ARNs de los repositorios ECR"
  type        = list(string)
  default     = []
}