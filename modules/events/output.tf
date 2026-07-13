
# OUTPUTS DE RECURSOS DE MENSAJERÍA (SNS & SQS)


output "sns_topic_arn" {
  description = "ARN del tema SNS existente"
  value       = data.aws_sns_topic.existing.arn
}

output "sns_topic_name" {
  description = "Nombre del tema SNS existente"
  value       = data.aws_sns_topic.existing.name
}

output "sqs_queue_arn" {
  description = "ARN de la cola SQS existente"
  value       = data.aws_sqs_queue.existing.arn
}

output "sqs_queue_url" {
  description = "URL de la cola SQS existente"
  value       = data.aws_sqs_queue.existing.id
}

output "sqs_queue_name" {
  description = "Nombre de la cola SQS existente"
  value       = data.aws_sqs_queue.existing.name
}

output "sns_subscriptions" {
  description = "IDs de las suscripciones válidas de SNS"
  value = {
    sqs = aws_sns_topic_subscription.this.id
  }
}


# OUTPUTS DE RECURSOS S3


output "s3_bucket_arn" {
  description = "ARN del bucket S3 existente"
  value       = data.aws_s3_bucket.existing.arn
}

output "s3_bucket_id" {
  description = "ID del bucket S3 existente"
  value       = data.aws_s3_bucket.existing.id
}


# OUTPUTS DE COMPUTO (LAMBDA FUNCTION)


output "lambda_function_arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.this.arn
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.this.function_name
}

output "event_source_mapping_id" {
  description = "ID del mapping de integración SQS → Lambda"
  value       = aws_lambda_event_source_mapping.sqs_trigger.id
}

output "lambda_environment_variables" {
  description = "Variables de entorno configuradas en Lambda"
  value       = aws_lambda_function.this.environment[0].variables
  sensitive   = true # Protege las credenciales inyectadas en la consola
}


# OUTPUTS DE SEGURIDAD E IDENTIDAD (SECRETS & COGNITO)


output "secret_name" {
  description = "Nombre del secreto en AWS Secrets Manager"
  value       = data.aws_secretsmanager_secret.db_credentials.name
}

output "secret_arn" {
  description = "ARN del secreto en AWS Secrets Manager"
  value       = data.aws_secretsmanager_secret.db_credentials.arn
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = data.aws_cognito_user_pool.main.id
}

output "cognito_client_id" {
  description = "ID del Client de Cognito obtenido por variable"
  value       = var.cognito_client_id
}


# OUTPUTS DE MONITOREO Y CONTROL (CLOUDWATCH & BUDGETS)

output "cloudwatch_log_group_name" {
  description = "Nombre del grupo de logs de CloudWatch para Lambda"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN del grupo de logs de CloudWatch para Lambda"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "cloudwatch_alarms" {
  description = "Información consolidada de las alarmas de CloudWatch"
  value = {
    sqs_queue_depth = {
      arn       = aws_cloudwatch_metric_alarm.sqs_queue_depth.arn
      name      = aws_cloudwatch_metric_alarm.sqs_queue_depth.alarm_name
      threshold = aws_cloudwatch_metric_alarm.sqs_queue_depth.threshold
    }
    lambda_errors = {
      arn       = aws_cloudwatch_metric_alarm.lambda_errors.arn
      name      = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
      threshold = aws_cloudwatch_metric_alarm.lambda_errors.threshold
    }
    lambda_duration = {
      arn       = aws_cloudwatch_metric_alarm.lambda_duration.arn
      name      = aws_cloudwatch_metric_alarm.lambda_duration.alarm_name
      threshold = aws_cloudwatch_metric_alarm.lambda_duration.threshold
    }
  }
}

output "alerts_sns_topic_arn" {
  description = "ARN del tema SNS para el control de alertas de infraestructura"
  value       = try(aws_sns_topic.alerts[0].arn, null)
}

output "budget_name" {
  description = "Nombre del presupuesto asignado a la infraestructura de eventos"
  value       = try(aws_budgets_budget.events_budget[0].name, null)
}
