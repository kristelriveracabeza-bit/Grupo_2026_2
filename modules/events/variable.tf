# VARIABLES BÁSICAS DEL PROYECTO

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "dermatologia"  
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
  default     = "prod"  
}

# VARIABLES PARA RECURSOS 

variable "existing_sns_topic_name" {
  description = "Nombre del tema SNS existente (ej: Dermatologia_Probando.fifo)"
  type        = string
  default     = "Dermatologia_Probando.fifo"  
}

variable "existing_sqs_queue_name" {
  description = "Nombre de la cola SQS existente (ej: Dermatologia o Dermatologia.fifo)"
  type        = string
  default     = "Dermatologia"  
}

variable "existing_s3_bucket_name" {
  description = "Nombre del bucket S3 existente"
  type        = string
  default     = "dermaimagenes"  
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda existente"
  type        = string
  default     = "Dermatologia_Reverva_de_Cita"  
}

variable "lambda_role_name" {
  description = "Nombre del rol IAM que usa la Lambda"
  type        = string
  default     = null  
}

# VARIABLES PARA CREAR RECURSOS NUEVOS 

variable "create_new_sns_topic" {
  description = "Si es true, crea un nuevo SNS topic. Si es false, usa el existente"
  type        = bool
  default     = false  
}

variable "new_sns_topic_name" {
  description = "Nombre para crear un nuevo tema SNS (solo si create_new_sns_topic = true)"
  type        = string
  default     = null
}

variable "new_sns_topic_fifo" {
  description = "Si el nuevo SNS topic debe ser FIFO"
  type        = bool
  default     = true  
}

variable "create_new_sqs_queue" {
  description = "Si es true, crea una nueva cola SQS. Si es false, usa la existente"
  type        = bool
  default     = false
}

variable "new_sqs_queue_name" {
  description = "Nombre para crear una nueva cola SQS (solo si create_new_sqs_queue = true)"
  type        = string
  default     = null
}

variable "new_sqs_queue_fifo" {
  description = "Si la nueva cola SQS debe ser FIFO (requerido si SNS es FIFO)"
  type        = bool
  default     = true
}

variable "create_new_s3_bucket" {
  description = "Si es true, crea un nuevo bucket S3. Si es false, usa el existente"
  type        = bool
  default     = false
}

variable "new_s3_bucket_name" {
  description = "Nombre para crear un nuevo bucket S3 (solo si create_new_s3_bucket = true)"
  type        = string
  default     = null
}

# VARIABLES PARA LAMBDA 

variable "lambda_zip_path" {
  description = "Ruta del archivo ZIP de la Lambda"
  type        = string
  default     = "lambda.zip"
}

variable "lambda_handler" {
  description = "Handler de la Lambda"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Runtime de la Lambda"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Timeout de la Lambda en segundos"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memoria de la Lambda en MB"
  type        = number
  default     = 128
}


# VARIABLES ADICIONALES


variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default = {
    Project     = "Dermatologia"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

# VARIABLES PARA SECRETS MANAGER
variable "secret_name" {
  description = "Nombre del secret en AWS Secrets Manager para credenciales de base de datos"
  type        = string
  default     = "dermatologia/db-credentials"
}

# VARIABLES PARA COGNITO
variable "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito (ej: us-east-1_XXXXX)"
  type        = string
  default     = "us-east-1_XXXXXXXXX"  
}

variable "cognito_client_id" {
  description = "ID del Client de Cognito (ej: 1234567890abcdefghij)"
  type        = string
  default     = "XXXXXXXXXXXXXXXXXXXX"  
}

# VARIABLES PARA MICROSERVICIOS ECS
variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
  default     = "dermatologia-cluster"
}

variable "appointments_service_name" {
  description = "Nombre del servicio ECS para gestión de citas"
  type        = string
  default     = "appointments-service"
}

variable "patients_service_name" {
  description = "Nombre del servicio ECS para gestión de pacientes"
  type        = string
  default     = "patients-service"
}

variable "appointments_endpoint" {
  description = "Endpoint HTTP del microservicio de citas"
  type        = string
  default     = "http://appointments-service.dermatologia.local:8080/events"
}

variable "patients_endpoint" {
  description = "Endpoint HTTP del microservicio de pacientes"
  type        = string
  default     = "http://patients-service.dermatologia.local:8080/events"
}

variable "enable_microservice_subscriptions" {
  description = "Habilitar suscripciones directas de SNS a microservicios ECS"
  type        = bool
  default     = true
}

# VARIABLES PARA CLOUDWATCH Y MONITOREO
variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
  default     = 30
}

variable "sqs_depth_threshold" {
  description = "Umbral de mensajes en cola SQS para activar alarma"
  type        = number
  default     = 100
}

variable "lambda_duration_threshold" {
  description = "Umbral de duración de Lambda en milisegundos para activar alarma"
  type        = number
  default     = 25000  
}

# VARIABLES PARA SNS DE ALERTAS
variable "create_alerts_topic" {
  description = "Crear un SNS topic separado para alertas"
  type        = bool
  default     = true
}

# VARIABLES PARA AWS BUDGETS
variable "create_budget" {
  description = "Crear un presupuesto de AWS para el módulo events"
  type        = bool
  default     = true
}

variable "budget_limit_amount" {
  description = "Monto límite del presupuesto en USD"
  type        = string
  default     = "50"
}

variable "budget_threshold_first" {
  description = "Primer umbral de alerta de presupuesto (porcentaje)"
  type        = number
  default     = 80
}

variable "budget_threshold_second" {
  description = "Segundo umbral de alerta de presupuesto (porcentaje)"
  type        = number
  default     = 100
}

variable "budget_alert_emails" {
  description = "Lista de correos electrónicos para alertas de presupuesto"
  type        = list(string)
  default     = ["admin@clinica.com"]
}