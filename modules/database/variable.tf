
# VARIABLES GENERALES

variable "project_name" {
  description = "Nombre del proyecto para nombrar recursos"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegarán los recursos"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de subnets privadas"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Lista de IDs de tablas de ruta privadas"
  type        = list(string)
}

variable "tags" {
  description = "Tags comunes para aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}

# VARIABLES PARA DYNAMODB

variable "dynamodb_billing_mode" {
  description = "Modo de facturación para DynamoDB (PROVISIONED o PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  description = "Capacidad de lectura para DynamoDB (requerido si billing_mode es PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Capacidad de escritura para DynamoDB (requerido si billing_mode es PROVISIONED)"
  type        = number
  default     = 5
}

variable "enable_pitr" {
  description = "Habilitar Point-in-Time Recovery para tablas DynamoDB"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Habilitar TTL para tablas DynamoDB"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN de la KMS key para cifrado"
  type        = string
  default     = null
}

# VARIABLES PARA ELASTICACHE (REDIS)


variable "redis_port" {
  description = "Puerto para Redis"
  type        = number
  default     = 6379
}

variable "redis_node_type" {
  description = "Tipo de nodo para Redis (ej: cache.t3.micro, cache.t3.small)"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "Número de nodos de caché Redis"
  type        = number
  default     = 1
}

variable "redis_snapshot_retention_days" {
  description = "Días de retención de snapshots de Redis"
  type        = number
  default     = 7
}

variable "redis_snapshot_window" {
  description = "Ventana de tiempo para snapshots de Redis (formato HH:MM-HH:MM)"
  type        = string
  default     = "03:00-04:00"
}

variable "redis_cpu_alarm_threshold" {
  description = "Umbral de CPU para alarma de Redis (%)"
  type        = number
  default     = 75
}

# VARIABLES PARA OPENSEARCH

variable "opensearch_port" {
  description = "Puerto para OpenSearch"
  type        = number
  default     = 443
}

variable "opensearch_instance_type" {
  description = "Tipo de instancia para OpenSearch"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "Número de instancias para OpenSearch"
  type        = number
  default     = 2
}

variable "opensearch_zone_awareness" {
  description = "Habilitar zone awareness para OpenSearch"
  type        = bool
  default     = true
}

variable "opensearch_dedicated_master_enabled" {
  description = "Habilitar nodos maestros dedicados en OpenSearch"
  type        = bool
  default     = false
}

variable "opensearch_dedicated_master_type" {
  description = "Tipo de instancia para nodos maestros dedicados"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_dedicated_master_count" {
  description = "Número de nodos maestros dedicados"
  type        = number
  default     = 3
}

variable "opensearch_volume_size" {
  description = "Tamaño del volumen EBS para OpenSearch en GB"
  type        = number
  default     = 10
}

variable "opensearch_master_user" {
  description = "Usuario maestro para OpenSearch"
  type        = string
  default     = "admin"
}

variable "opensearch_master_password" {
  description = "Contraseña maestra para OpenSearch"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "opensearch_snapshot_hour" {
  description = "Hora para snapshot automático de OpenSearch (0-23)"
  type        = number
  default     = 0
}

variable "opensearch_cpu_alarm_threshold" {
  description = "Umbral de CPU para alarma de OpenSearch (%)"
  type        = number
  default     = 75
}

# VARIABLES PARA S3

variable "s3_bucket_name" {
  description = "Nombre del bucket S3 (si es null, se genera automáticamente)"
  type        = string
  default     = null
}

variable "s3_transition_days" {
  description = "Días después de los cuales los objetos se mueven a Glacier"
  type        = number
  default     = 90
}

variable "s3_noncurrent_version_expiration_days" {
  description = "Días después de los cuales expiran las versiones no actuales"
  type        = number
  default     = 30
}

# VARIABLES PARA CLOUDWATCH ALARMS

variable "enable_db_alarms" {
  description = "Habilitar alarmas de CloudWatch para recursos de base de datos"
  type        = bool
  default     = true
}

variable "dynamodb_throttle_alarm_threshold" {
  description = "Umbral para alarma de solicitudes throttled en DynamoDB"
  type        = number
  default     = 10
}

variable "sns_topic_arn" {
  description = "ARN del tópico SNS para notificaciones de alarmas"
  type        = string
  default     = ""
}

# VARIABLES PARA SEGURIDAD Y ACCESO

variable "application_security_group_ids" {
  description = "IDs de los security groups de las aplicaciones que acceden a Redis y OpenSearch"
  type        = list(string)
  default     = []
}

variable "application_role_arn" {
  description = "ARN del rol IAM de la aplicación para acceder a OpenSearch"
  type        = string
  default     = ""
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos para acceder a OpenSearch"
  type        = list(string)
  default     = []
}

# VARIABLES PARA SECRETS MANAGER

variable "create_db_secret" {
  description = "Crear un secreto en Secrets Manager"
  type        = bool
  default     = true
}
variable "cloudwatch_log_retention_days" {
  description = "Días de retención para los logs de CloudWatch"
  type        = number
  default     = 30
}
