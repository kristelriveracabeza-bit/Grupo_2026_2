# DATA SOURCES 

data "aws_sns_topic" "existing" {
  name = "Dermatologia_Probando.fifo"  
}

data "aws_sqs_queue" "existing" {
  name = "Dermatologia"  
}

data "aws_s3_bucket" "existing" {
  bucket = "dermaimagenes"
}

data "aws_iam_role" "lambda" {
  name = var.lambda_role_name  
}

# DATA SOURCE PARA SECRETS MANAGER
data "aws_secretsmanager_secret" "db_credentials" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

# DATA SOURCE PARA COGNITO 
data "aws_cognito_user_pool" "main" {
  user_pool_id = var.cognito_user_pool_id
}

# DATA SOURCE PARA MICROSERVICIOS ECS
data "aws_ecs_cluster" "main" {
  cluster_name = var.ecs_cluster_name
}

data "aws_ecs_service" "appointments" {
  service_name = var.appointments_service_name
  cluster_arn  = data.aws_ecs_cluster.main.arn
}

data "aws_ecs_service" "patients" {
  service_name = var.patients_service_name
  cluster_arn  = data.aws_ecs_cluster.main.arn
}


# SNS TOPIC 

resource "aws_sns_topic" "this" {
  name         = "Dermatologia_Probando.fifo"
  fifo_topic   = true
  
  # Agregado para evitar warning de SonarLint
  kms_master_key_id = "alias/aws/sns"
}

# SQS QUEUE 
resource "aws_sqs_queue" "this" {
  name = "Dermatologia.fifo"  
  fifo_queue = true  
  
  # Configuraciones recomendadas para FIFO
  content_based_deduplication = true
}

# POLÍTICA SNS → SQS 
resource "aws_sns_topic_subscription" "this" {
  topic_arn = data.aws_sns_topic.existing.arn
  protocol  = "sqs"
  endpoint  = data.aws_sqs_queue.existing.arn
}


# Suscripción SNS → Microservicio de Citas
resource "aws_sns_topic_subscription" "ecs_appointments" {
  count = var.enable_microservice_subscriptions ? 1 : 0
  
  topic_arn = data.aws_sns_topic.existing.arn
  protocol  = "http"
  endpoint  = var.appointments_endpoint
  
  filter_policy = jsonencode({
    event_type = ["appointment_created", "appointment_updated", "appointment_cancelled"]
  })
}

# Suscripción SNS → Microservicio de Pacientes
resource "aws_sns_topic_subscription" "ecs_patients" {
  count = var.enable_microservice_subscriptions ? 1 : 0
  
  topic_arn = data.aws_sns_topic.existing.arn
  protocol  = "http"
  endpoint  = var.patients_endpoint
  
  filter_policy = jsonencode({
    event_type = ["patient_created", "patient_updated", "patient_deleted"]
  })
}



resource "aws_sqs_queue_policy" "this" {
  queue_url = data.aws_sqs_queue.existing.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action = "sqs:SendMessage"
      Resource = data.aws_sqs_queue.existing.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = data.aws_sns_topic.existing.arn
        }
      }
    }]
  })
}

# S3 BUCKET NOTIFICATION 

resource "aws_s3_bucket_notification" "this" {
  bucket = data.aws_s3_bucket.existing.id

  topic {
    topic_arn = data.aws_sns_topic.existing.arn
    events    = ["s3:ObjectCreated:*"]
    
    # Filtro opcional para solo ciertas imágenes
    filter_suffix = ".jpg"
  }
}

# POLÍTICA SNS PARA PERMITIR S3 
resource "aws_sns_topic_policy" "allow_s3" {
  arn = data.aws_sns_topic.existing.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowS3ToPublish"
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = data.aws_sns_topic.existing.arn
      Condition = {
        ArnEquals = { 
          "aws:SourceArn" = data.aws_s3_bucket.existing.arn
        }
      }
    }]
  })
}


# LAMBDA FUNCTION (con trigger SQS)

resource "aws_lambda_function" "this" {
  filename         = var.lambda_zip_path
  function_name    = "Dermatologia_Reverva_de_Cita"  
  role             = data.aws_iam_role.lambda.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      SQS_QUEUE_URL = data.aws_sqs_queue.existing.url
      SNS_TOPIC_ARN = data.aws_sns_topic.existing.arn
      # ===== NUEVAS VARIABLES DE ENTORNO AGREGADAS =====
      DB_CREDENTIALS     = data.aws_secretsmanager_secret_version.db_credentials.secret_string
      COGNITO_USER_POOL_ID = data.aws_cognito_user_pool.main.id
      COGNITO_CLIENT_ID  = var.cognito_client_id
      ENVIRONMENT        = var.environment
      # ===== FIN NUEVAS VARIABLES =====
    }
  }
}

# SQS → LAMBDA TRIGGER

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = data.aws_sqs_queue.existing.arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = 10
  enabled          = true
}

# CLOUDWATCH LOG GROUP PARA LAMBDA
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.tags
}

# CLOUDWATCH ALARMS PARA MONITOREO

# Alarma para profundidad de cola SQS
resource "aws_cloudwatch_metric_alarm" "sqs_queue_depth" {
  alarm_name          = "sqs-queue-depth-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.sqs_depth_threshold
  alarm_description  = "Alerta cuando la cola SQS tiene demasiados mensajes acumulados"
  
  dimensions = {
    QueueName = data.aws_sqs_queue.existing.name
  }
  
  alarm_actions = [aws_sns_topic.alerts[0].arn]
}

# Alarma para errores en Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "5"
  alarm_description  = "Alerta cuando la Lambda tiene demasiados errores"
  
  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }
  
  alarm_actions = [aws_sns_topic.alerts[0].arn]
}

# Alarma para duración de Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "lambda-duration-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Duration"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Average"
  threshold          = var.lambda_duration_threshold
  alarm_description  = "Alerta cuando la Lambda excede el tiempo de ejecución esperado"
  
  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }
  
  alarm_actions = [aws_sns_topic.alerts[0].arn]
}

# SNS TOPIC PARA ALERTAS
resource "aws_sns_topic" "alerts" {
  count = var.create_alerts_topic ? 1 : 0
  
  name = "${var.project_name}-alerts-${var.environment}"
  
  # Agregado para evitar warning de SonarLint
  kms_master_key_id = "alias/aws/sns"
  
  tags = var.tags
}

# AWS BUDGETS PARA CONTROL DE COSTOS
resource "aws_budgets_budget" "events_budget" {
  count = var.create_budget ? 1 : 0
  
  name         = "${var.project_name}-events-budget-${var.environment}"
  budget_type  = "COST"
  limit_amount = var.budget_limit_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_types {
    include_credit             = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = false
    include_upfront            = true
    use_amortized              = false
    use_blended                = false
  }
  
  notification {
    comparison_operator   = "GREATER_THAN"
    threshold            = var.budget_threshold_first
    threshold_type       = "PERCENTAGE"
    notification_type    = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
  
  notification {
    comparison_operator   = "GREATER_THAN"
    threshold            = var.budget_threshold_second
    threshold_type       = "PERCENTAGE"
    notification_type    = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }
}

