# SECURITY GROUP FOR ECS
resource "aws_security_group" "ecs" {
  name_prefix = "${var.project_name}-ecs-sg-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "From services in same VPC"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-ecs-sg-${var.environment}"
    Environment = var.environment
  })
}


# DEAD LETTER QUEUE (DLQ) PARA LAMBDA
resource "aws_sqs_queue" "lambda_dlq" {
  count = var.enable_lambda ? 1 : 0

  name = "${var.project_name}-lambda-dlq-${var.environment}"

  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 30

  tags = merge(var.tags, {
    Name        = "${var.project_name}-lambda-dlq-${var.environment}"
    Environment = var.environment
  })
}


# LAMBDA FUNCTION
resource "aws_lambda_function" "this" {
  count = var.enable_lambda ? 1 : 0

  filename      = var.lambda_zip_path
  function_name = var.lambda_function_name != null ? var.lambda_function_name : "${var.project_name}-function-${var.environment}"
  role          = var.lambda_role_arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  # Hacemos referencia al índice [0] de la DLQ ya que comparte el mismo count
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq[0].arn
  }

  environment {
    variables = {
      SQS_QUEUE_URL        = var.sqs_queue_url
      SNS_TOPIC_ARN        = var.sns_topic_arn
      ENVIRONMENT          = var.environment
      SECRET_NAME          = var.secret_name          
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id 
      COGNITO_CLIENT_ID    = var.cognito_client_id    
    }
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-lambda-${var.environment}"
    Environment = var.environment
  })
}


# POLÍTICA DE LA DLQ 
resource "aws_sqs_queue_policy" "lambda_dlq_policy" {
  count = var.enable_lambda ? 1 : 0

  queue_url = aws_sqs_queue.lambda_dlq[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.lambda_dlq[0].arn
        Condition = {
          ArnEquals = {
            # one() extrae el elemento de forma segura si existe, evitando errores si la lista está vacía
            "aws:SourceArn" = one(aws_lambda_function.this[*].arn)
          }
        }
      }
    ]
  })

  depends_on = [aws_lambda_function.this]
}


# SQS → LAMBDA TRIGGER
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count = var.enable_lambda ? 1 : 0

  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.this[0].arn
  batch_size       = 10
  enabled          = true
}


# CLOUDWATCH LOG GROUP PARA ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-app-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

# CKV2_AWS_73 — La cola SQS usa la clave de cifrado por defecto de AWS en vez de una clave propia. Con la clave por defecto, AWS controla el acceso; con clave propia, tú controlas quién puede descifrar los mensajes.
