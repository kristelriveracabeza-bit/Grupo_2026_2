
# OUTPUTS - CONFIGURACIÓN Y ESTADO


output "configuration_summary" {
  description = "Resumen de la configuración actual"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    region          = var.aws_region
    sns_topic       = var.sns_topic_name
    sqs_queue       = var.sqs_queue_name
    s3_bucket       = var.s3_bucket_name
    lambda_function = var.lambda_function_name
    cicd_enabled    = var.enable_cicd
    log_retention   = var.log_retention_days
    lambda_memory   = var.lambda_memory_size
    lambda_timeout  = var.lambda_timeout
    lambda_runtime  = var.lambda_runtime
  }
}

# ELIMINADO: output "sns_topic_fifo_status"
# ELIMINADO: output "sqs_queue_fifo_status"


# OUTPUTS - URLS DE CONSOLA AWS


output "sqs_console_url" {
  description = "URL de la consola de SQS"
  value       = "https://console.aws.amazon.com/sqs/v2/home?region=${var.aws_region}#/queues/${urlencode(module.events.sqs_queue_url)}"
}

output "sns_console_url" {
  description = "URL de la consola de SNS"
  value       = "https://console.aws.amazon.com/sns/v3/home?region=${var.aws_region}#/topic/${module.events.sns_topic_arn}"
}

output "lambda_console_url" {
  description = "URL de la consola de Lambda"
  value       = "https://console.aws.amazon.com/lambda/home?region=${var.aws_region}#/functions/${module.compute.lambda_function_name}"
}

output "s3_console_url" {
  description = "URL de la consola de S3"
  value       = "https://s3.console.aws.amazon.com/s3/buckets/${module.events.s3_bucket_id}?region=${var.aws_region}"
}

output "secrets_manager_console_url" {
  description = "URL de la consola de Secrets Manager"
  value       = "https://console.aws.amazon.com/secretsmanager/home?region=${var.aws_region}#/secret?name=${var.secret_name}"
}

output "ecs_console_url" {
  description = "URL de la consola de ECS"
  value       = "https://console.aws.amazon.com/ecs/v2/clusters/${module.compute.ecs_cluster_name}/services?region=${var.aws_region}"
}

output "pipeline_console_url" {
  description = "URL de la consola de CodePipeline"
  value       = var.enable_cicd ? "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${module.cicd[0].codepipeline_name}/view?region=${var.aws_region}" : null
}


# OUTPUTS - COMANDOS ÚTILES AWS CLI


# ELIMINADO: output "test_sns_publish_command" (usaba var.sns_topic_fifo)

output "test_sqs_receive_command" {
  description = "Comando para recibir mensajes de SQS"
  value       = "aws sqs receive-message --queue-url ${module.events.sqs_queue_url} --region ${var.aws_region} --max-number-of-messages 10 --attribute-names All --message-attribute-names All"
}

output "test_lambda_invoke_command" {
  description = "Comando para invocar la función Lambda con un evento de prueba"
  value       = "aws lambda invoke --function-name ${module.compute.lambda_function_name} --payload '{\"event_type\":\"test\",\"data\":{\"message\":\"Hello from CLI\"}}' --region ${var.aws_region} response.json && cat response.json"
}

output "view_lambda_logs_command" {
  description = "Comando para ver los logs de Lambda en CloudWatch"
  value       = "aws logs filter-log-events --log-group-name /aws/lambda/${module.compute.lambda_function_name} --region ${var.aws_region} --limit 20"
}


# OUTPUTS - INFORMACIÓN PARA SCRIPTS


output "deployment_info" {
  description = "Información de despliegue para scripts"
  value = {
    region        = var.aws_region
    project       = var.project_name
    environment   = var.environment
    lambda_name   = module.compute.lambda_function_name
    sqs_url       = module.events.sqs_queue_url
    sns_arn       = module.events.sns_topic_arn
    s3_bucket     = module.events.s3_bucket_id
    ecs_cluster   = module.compute.ecs_cluster_name
    pipeline_name = var.enable_cicd ? module.cicd[0].codepipeline_name : null
  }
}

