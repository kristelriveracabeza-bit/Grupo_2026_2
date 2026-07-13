# OUTPUTS DEL MÓDULO COMPUTE


# ECS OUTPUTS


output "ecs_cluster_id" {
  description = "ID del cluster ECS"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.this.name
}

output "ecs_cluster_arn" {
  description = "ARN del cluster ECS"
  value       = aws_ecs_cluster.this.arn
}

output "ecs_task_definition_arn" {
  description = "ARN de la task definition de ECS"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_revision" {
  description = "Revisión de la task definition de ECS"
  value       = aws_ecs_task_definition.app.revision
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS"
  value       = aws_ecs_service.app.name
}

output "ecs_service_id" {
  description = "ID del servicio ECS"
  value       = aws_ecs_service.app.id
}


# TARGET GROUP OUTPUTS


output "target_group_blue_arn" {
  description = "ARN del target group Blue"
  value       = aws_lb_target_group.blue.arn
}

output "target_group_blue_name" {
  description = "Nombre del target group Blue"
  value       = aws_lb_target_group.blue.name
}

output "target_group_green_arn" {
  description = "ARN del target group Green"
  value       = aws_lb_target_group.green.arn
}

output "target_group_green_name" {
  description = "Nombre del target group Green"
  value       = aws_lb_target_group.green.name
}


# SERVICE DISCOVERY OUTPUTS


output "service_discovery_namespace_id" {
  description = "ID del namespace de Service Discovery"
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "service_discovery_namespace_name" {
  description = "Nombre del namespace de Service Discovery"
  value       = aws_service_discovery_private_dns_namespace.this.name
}

output "service_discovery_service_name" {
  description = "Nombre del servicio de Service Discovery"
  value       = aws_service_discovery_service.app.name
}


# AUTO SCALING OUTPUTS


output "autoscaling_target_id" {
  description = "ID del target de Auto Scaling"
  value       = aws_appautoscaling_target.ecs.id
}

output "autoscaling_min_capacity" {
  description = "Capacidad mínima de Auto Scaling"
  value       = var.ecs_min_capacity
}

output "autoscaling_max_capacity" {
  description = "Capacidad máxima de Auto Scaling"
  value       = var.ecs_max_capacity
}


# SECURITY GROUP OUTPUTS


output "ecs_security_group_id" {
  description = "ID del security group de ECS"
  value       = aws_security_group.ecs.id
}


# LAMBDA OUTPUTS


output "lambda_function_arn" {
  description = "ARN de la función Lambda"
  value       = var.enable_lambda ? aws_lambda_function.this[0].arn : null
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = var.enable_lambda ? aws_lambda_function.this[0].function_name : null
}

output "lambda_event_source_mapping_uuid" {
  description = "UUID del mapeo de origen de eventos (SQS → Lambda)"
  value       = var.enable_lambda ? aws_lambda_event_source_mapping.sqs_trigger[0].uuid : null
}

output "lambda_dlq_arn" {
  description = "ARN de la DLQ de Lambda"
  value       = var.enable_lambda ? aws_sqs_queue.lambda_dlq[0].arn : null
}

output "lambda_dlq_url" {
  description = "URL de la DLQ de Lambda"
  value       = var.enable_lambda ? aws_sqs_queue.lambda_dlq[0].id : null
}


# CLOUDWATCH LOGS


output "ecs_log_group_name" {
  description = "Nombre del log group de ECS"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "ecs_log_group_arn" {
  description = "ARN del log group de ECS"
  value       = aws_cloudwatch_log_group.ecs.arn
}
