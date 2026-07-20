
# VARIABLES BÁSICAS DEL PROYECTO


variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "dermatologia"
}

variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
  default     = "prod"
}


# VARIABLES PARA RECURSOS EXISTENTES (DATA SOURCES)


variable "existing_sns_topic_name" {
  description = "Nombre del tema SNS existente"
  type        = string
  default     = "Dermatologia_Probando.fifo"
}

variable "existing_sqs_queue_name" {
  description = "Nombre de la cola SQS existente (Debe terminar en .fifo)"
  type        = string
  default     = "Dermatologia.fifo"
}

variable "existing_s3_bucket_name" {
  description = "Nombre del bucket S3 existente para almacenamiento de imágenes"
  type        = string
  default     = "dermaimagenes"
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda existente para Reserva de Citas"
  type        = string
  default     = "Dermatologia_Reverva_de_Cita"
}

variable "lambda_role_name" {
  description = "Nombre del rol IAM asignado a la ejecución de la Lambda"
  type        = string
  default     = "dermatologia-lambda-role" # Se asigna un valor por defecto seguro en lugar de null
}


# VARIABLES PARA CONTROL DE CREACIÓN OPCIONAL DE RECURSOS


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
  description = "Define si el nuevo SNS topic debe configurarse como FIFO"
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
  description = "Define si la nueva cola SQS debe ser FIFO (requerido si el flujo es FIFO)"
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


# VARIABLES DE CONFIGURACIÓN DE LAMBDA


variable "lambda_zip_path" {
  description = "Ruta local del archivo ejecutable ZIP de la Lambda"
  type        = string
  default     = "lambda.zip"
}

variable "lambda_handler" {
  description = "Punto de entrada (Handler) de la función Lambda"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Entorno de ejecución (Runtime) para la función Lambda"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Tiempo límite de ejecución de la Lambda en segundos"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Cantidad de memoria asignada a la Lambda en MB"
  type        = number
  default     = 128
}


# VARIABLES PARA SERVICIOS EXTERNOS (SECRETS, COGNITO, ECS)


variable "secret_name" {
  description = "Nombre del secreto en AWS Secrets Manager que contiene las credenciales de la BD"
  type        = string
  default     = "dermatologia/db-credentials"
}

variable "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito para la autenticación"
  type        = string
  default     = "us-east-1_XXXXXXXXX"
}

variable "cognito_client_id" {
  description = "ID de la aplicación cliente (Client ID) de Cognito"
  type        = string
  default     = "XXXXXXXXXXXXXXXXXXXX"
}

variable "ecs_cluster_name" {
  description = "Nombre del cluster de ECS existente"
  type        = string
  default     = "dermatologia-cluster"
}

variable "appointments_service_name" {
  description = "Nombre del microservicio ECS encargado de las citas"
  type        = string
  default     = "appointments-service"
}

variable "patients_service_name" {
  description = "Nombre del microservicio ECS encargado de los pacientes"
  type        = string
  default     = "patients-service"
}


# VARIABLES PARA MONITOREO Y ALERTAS (CLOUDWATCH)


variable "log_retention_days" {
  description = "Días de retención para el CloudWatch Log Group de la Lambda"
  type        = number
  default     = 30
}

variable "sqs_depth_threshold" {
  description = "Cantidad límite de mensajes visibles en cola antes de disparar la alarma"
  type        = number
  default     = 100
}

variable "lambda_duration_threshold" {
  description = "Umbral crítico de duración promedio de la Lambda en milisegundos"
  type        = number
  default     = 25000 # 25 segundos
}

variable "create_alerts_topic" {
  description = "Determina si se creará el tópico SNS dedicado para alertaría de infraestructura"
  type        = bool
  default     = true
}


# VARIABLES PARA CONTROL DE COSTOS (AWS BUDGETS)


variable "create_budget" {
  description = "Habilitar la creación de un presupuesto de AWS Budgets"
  type        = bool
  default     = true
}

variable "budget_limit_amount" {
  description = "Límite del presupuesto mensual en USD"
  type        = string
  default     = "50"
}

variable "budget_threshold_first" {
  description = "Primer umbral porcentual de alerta de costos esperados (Forecasted)"
  type        = number
  default     = 80
}

variable "budget_threshold_second" {
  description = "Segundo umbral porcentual de alerta sobre costos reales acumulados (Actual)"
  type        = number
  default     = 100
}

variable "budget_alert_emails" {
  description = "Lista de correos electrónicos encargados de recibir notificaciones de costos"
  type        = list(string)
  default     = ["admin@clinica.com"]
}


# ETIQUETADO GENERAL (TAGS)


variable "tags" {
  description = "Metadatos organizacionales aplicables a todos los recursos creados"
  type        = map(string)
  default = {
    Project     = "Dermatologia"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
