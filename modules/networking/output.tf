
# OUTPUTS DE LA VPC

output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "ARN de la VPC"
  value       = aws_vpc.this.arn
}


# OUTPUTS DE SUBNETS PÚBLICAS

output "public_subnet_ids" {
  description = "Lista de IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "Lista de ARNs de las subredes públicas"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidrs" {
  description = "Lista de CIDR blocks de las subredes públicas"
  value       = aws_subnet.public[*].cidr_block
}


# OUTPUTS DE SUBNETS PRIVADAS

output "private_subnet_ids" {
  description = "Lista de IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "Lista de ARNs de las subredes privadas"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidrs" {
  description = "Lista de CIDR blocks de las subredes privadas"
  value       = aws_subnet.private[*].cidr_block
}

# OUTPUTS DE TABLAS DE RUTEO
output "public_route_table_id" {
  description = "ID de la tabla de ruteo pública"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID de la tabla de ruteo privada"
  value       = aws_route_table.private.id
}

output "private_route_table_ids" {
  description = "Lista de IDs de las tablas de ruteo privadas (para VPC Endpoints)"
  value       = [aws_route_table.private.id]
}

# OUTPUTS DE NAT GATEWAY

output "nat_gateway_ids" {
  description = "IDs de los NAT Gateways (si están habilitados)"
  value       = try(aws_nat_gateway.this[*].id, [])
}

output "nat_public_ips" {
  description = "IPs públicas de los NAT Gateways"
  value       = try(aws_eip.nat[*].public_ip, [])
}

output "nat_gateway_enabled" {
  description = "Indica si el NAT Gateway está habilitado"
  value       = var.enable_nat_gateway
}

# OUTPUTS DE INTERNET GATEWAY

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.this.id
}

# OUTPUTS DE VPC ENDPOINTS (GATEWAY)

output "vpc_endpoint_s3_id" {
  description = "ID del VPC Endpoint para S3"
  value       = var.enable_s3_vpc_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "vpc_endpoint_s3_arn" {
  description = "ARN del VPC Endpoint para S3"
  value       = var.enable_s3_vpc_endpoint ? aws_vpc_endpoint.s3[0].arn : null
}

output "vpc_endpoint_dynamodb_id" {
  description = "ID del VPC Endpoint para DynamoDB"
  value       = var.enable_dynamodb_vpc_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "vpc_endpoint_dynamodb_arn" {
  description = "ARN del VPC Endpoint para DynamoDB"
  value       = var.enable_dynamodb_vpc_endpoint ? aws_vpc_endpoint.dynamodb[0].arn : null
}

output "s3_vpc_endpoint_route_tables" {
  description = "Route tables asociadas al VPC Endpoint de S3"
  value       = var.enable_s3_vpc_endpoint ? aws_vpc_endpoint.s3[0].route_table_ids : []
}


# OUTPUTS DE VPC ENDPOINTS (INTERFACE)

output "vpc_endpoint_sqs_id" {
  description = "ID del VPC Endpoint para SQS"
  value       = var.enable_sqs_vpc_endpoint ? aws_vpc_endpoint.sqs[0].id : null
}

output "vpc_endpoint_sqs_arn" {
  description = "ARN del VPC Endpoint para SQS"
  value       = var.enable_sqs_vpc_endpoint ? aws_vpc_endpoint.sqs[0].arn : null
}

output "vpc_endpoint_sqs_dns" {
  description = "DNS del VPC Endpoint para SQS"
  value       = var.enable_sqs_vpc_endpoint ? aws_vpc_endpoint.sqs[0].dns_entry[0].dns_name : null
}

output "vpc_endpoint_sns_id" {
  description = "ID del VPC Endpoint para SNS"
  value       = var.enable_sns_vpc_endpoint ? aws_vpc_endpoint.sns[0].id : null
}

output "vpc_endpoint_sns_arn" {
  description = "ARN del VPC Endpoint para SNS"
  value       = var.enable_sns_vpc_endpoint ? aws_vpc_endpoint.sns[0].arn : null
}

output "vpc_endpoint_ecr_api_id" {
  description = "ID del VPC Endpoint para ECR API"
  value       = var.enable_ecr_vpc_endpoint ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "vpc_endpoint_ecr_api_arn" {
  description = "ARN del VPC Endpoint para ECR API"
  value       = var.enable_ecr_vpc_endpoint ? aws_vpc_endpoint.ecr_api[0].arn : null
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "ID del VPC Endpoint para ECR DKR"
  value       = var.enable_ecr_vpc_endpoint ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "vpc_endpoint_ecr_dkr_arn" {
  description = "ARN del VPC Endpoint para ECR DKR"
  value       = var.enable_ecr_vpc_endpoint ? aws_vpc_endpoint.ecr_dkr[0].arn : null
}

output "vpc_endpoint_secretsmanager_id" {
  description = "ID del VPC Endpoint para Secrets Manager"
  value       = var.enable_secretsmanager_vpc_endpoint ? aws_vpc_endpoint.secretsmanager[0].id : null
}

output "vpc_endpoint_secretsmanager_arn" {
  description = "ARN del VPC Endpoint para Secrets Manager"
  value       = var.enable_secretsmanager_vpc_endpoint ? aws_vpc_endpoint.secretsmanager[0].arn : null
}

output "vpc_endpoint_cloudwatch_logs_id" {
  description = "ID del VPC Endpoint para CloudWatch Logs"
  value       = var.enable_cloudwatch_vpc_endpoint ? aws_vpc_endpoint.cloudwatch_logs[0].id : null
}

output "vpc_endpoint_cloudwatch_logs_arn" {
  description = "ARN del VPC Endpoint para CloudWatch Logs"
  value       = var.enable_cloudwatch_vpc_endpoint ? aws_vpc_endpoint.cloudwatch_logs[0].arn : null
}

output "vpc_endpoint_cloudwatch_monitoring_id" {
  description = "ID del VPC Endpoint para CloudWatch Monitoring"
  value       = var.enable_cloudwatch_vpc_endpoint ? aws_vpc_endpoint.cloudwatch_monitoring[0].id : null
}

output "vpc_endpoint_cloudwatch_monitoring_arn" {
  description = "ARN del VPC Endpoint para CloudWatch Monitoring"
  value       = var.enable_cloudwatch_vpc_endpoint ? aws_vpc_endpoint.cloudwatch_monitoring[0].arn : null
}

output "vpc_endpoint_opensearch_id" {
  description = "ID del VPC Endpoint para OpenSearch"
  value       = var.enable_opensearch_vpc_endpoint ? aws_vpc_endpoint.opensearch[0].id : null
}

output "vpc_endpoint_opensearch_arn" {
  description = "ARN del VPC Endpoint para OpenSearch"
  value       = var.enable_opensearch_vpc_endpoint ? aws_vpc_endpoint.opensearch[0].arn : null
}

output "vpc_endpoint_elasticache_id" {
  description = "ID del VPC Endpoint para ElastiCache"
  value       = var.enable_elasticache_vpc_endpoint ? aws_vpc_endpoint.elasticache[0].id : null
}

output "vpc_endpoint_elasticache_arn" {
  description = "ARN del VPC Endpoint para ElastiCache"
  value       = var.enable_elasticache_vpc_endpoint ? aws_vpc_endpoint.elasticache[0].arn : null
}

output "vpc_endpoint_ecs_id" {
  description = "ID del VPC Endpoint para ECS"
  value       = var.enable_ecs_vpc_endpoint ? aws_vpc_endpoint.ecs[0].id : null
}

output "vpc_endpoint_ecs_arn" {
  description = "ARN del VPC Endpoint para ECS"
  value       = var.enable_ecs_vpc_endpoint ? aws_vpc_endpoint.ecs[0].arn : null
}

output "vpc_endpoint_ecs_agent_id" {
  description = "ID del VPC Endpoint para ECS Agent"
  value       = var.enable_ecs_vpc_endpoint ? aws_vpc_endpoint.ecs_agent[0].id : null
}

output "vpc_endpoint_ecs_agent_arn" {
  description = "ARN del VPC Endpoint para ECS Agent"
  value       = var.enable_ecs_vpc_endpoint ? aws_vpc_endpoint.ecs_agent[0].arn : null
}

output "vpc_endpoint_ecs_telemetry_id" {
  description = "ID del VPC Endpoint para ECS Telemetry"
  value       = var.enable_ecs_vpc_endpoint ? aws_vpc_endpoint.ecs_telemetry[0].id : null
}

output "vpc_endpoint_ecs_telemetry_arn" {
  description = "ARN del VPC Endpoint para ECS Telemetry"
  value       = var.enable_ecs_vpc_endpoint ? aws_vpc_endpoint.ecs_telemetry[0].arn : null
}

# OUTPUTS DE AWS CLOUD MAP

output "cloud_map_namespace_id" {
  description = "ID del namespace de Cloud Map"
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "cloud_map_namespace_arn" {
  description = "ARN del namespace de Cloud Map"
  value       = aws_service_discovery_private_dns_namespace.this.arn
}

output "cloud_map_namespace_name" {
  description = "Nombre del namespace de Cloud Map"
  value       = aws_service_discovery_private_dns_namespace.this.name
}

output "cloud_map_service_appointments_id" {
  description = "ID del servicio Cloud Map para appointments"
  value       = aws_service_discovery_service.appointments.id
}

output "cloud_map_service_appointments_arn" {
  description = "ARN del servicio Cloud Map para appointments"
  value       = aws_service_discovery_service.appointments.arn
}

output "cloud_map_service_patients_id" {
  description = "ID del servicio Cloud Map para patients"
  value       = aws_service_discovery_service.patients.id
}

output "cloud_map_service_patients_arn" {
  description = "ARN del servicio Cloud Map para patients"
  value       = aws_service_discovery_service.patients.arn
}

# OUTPUTS DE ROUTE 53

output "route53_record_alb_name" {
  description = "Nombre del registro Route 53 para el ALB"
  value       = var.create_route53_records ? aws_route53_record.alb[0].name : null
}

output "route53_record_alb_fqdn" {
  description = "FQDN del registro Route 53 para el ALB"
  value       = var.create_route53_records ? aws_route53_record.alb[0].fqdn : null
}

output "route53_record_alb_zone_id" {
  description = "Zone ID del registro Route 53 para el ALB"
  value       = var.create_route53_records ? aws_route53_record.alb[0].zone_id : null
}

# OUTPUTS DE SECURITY GROUPS

output "alb_security_group_id" {
  description = "ID del Security Group del Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "ARN del Security Group del ALB"
  value       = aws_security_group.alb.arn
}

output "ecs_security_group_id" {
  description = "ID del Security Group de los servicios ECS"
  value       = aws_security_group.ecs.id
}

output "ecs_security_group_arn" {
  description = "ARN del Security Group de ECS"
  value       = aws_security_group.ecs.arn
}

output "rds_security_group_id" {
  description = "ID del Security Group de la base de datos RDS/Aurora"
  value       = var.create_rds_security_group ? aws_security_group.rds[0].id : null
}

output "rds_security_group_arn" {
  description = "ARN del Security Group de RDS"
  value       = var.create_rds_security_group ? aws_security_group.rds[0].arn : null
}

output "redis_security_group_id" {
  description = "ID del Security Group de Redis"
  value       = var.create_redis_security_group ? aws_security_group.redis[0].id : null
}

output "redis_security_group_arn" {
  description = "ARN del Security Group de Redis"
  value       = var.create_redis_security_group ? aws_security_group.redis[0].arn : null
}

output "opensearch_security_group_id" {
  description = "ID del Security Group de OpenSearch"
  value       = var.create_opensearch_security_group ? aws_security_group.opensearch[0].id : null
}

output "opensearch_security_group_arn" {
  description = "ARN del Security Group de OpenSearch"
  value       = var.create_opensearch_security_group ? aws_security_group.opensearch[0].arn : null
}

output "vpc_endpoints_security_group_id" {
  description = "ID del Security Group para VPC Endpoints"
  value       = var.enable_vpc_endpoints_security_group ? aws_security_group.vpc_endpoints[0].id : null
}

output "vpc_endpoints_security_group_arn" {
  description = "ARN del Security Group para VPC Endpoints"
  value       = var.enable_vpc_endpoints_security_group ? aws_security_group.vpc_endpoints[0].arn : null
}

# OUTPUTS DE VPC FLOW LOGS

output "vpc_flow_logs_group_name" {
  description = "Nombre del log group de VPC Flow Logs"
  value       = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

output "vpc_flow_logs_group_arn" {
  description = "ARN del log group de VPC Flow Logs"
  value       = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].arn : null
}

output "vpc_flow_log_id" {
  description = "ID del VPC Flow Log"
  value       = var.enable_vpc_flow_logs ? aws_flow_log.vpc[0].id : null
}

output "vpc_flow_logs_enabled" {
  description = "Indica si los VPC Flow Logs están habilitados"
  value       = var.enable_vpc_flow_logs
}

# OUTPUTS DE NETWORK ACLS

output "network_acl_public_id" {
  description = "ID de la Network ACL pública"
  value       = aws_network_acl.public.id
}

output "network_acl_private_id" {
  description = "ID de la Network ACL privada"
  value       = aws_network_acl.private.id
}


# OUTPUTS DE ZONAS DE DISPONIBILIDAD

output "availability_zones" {
  description = "Lista de zonas de disponibilidad utilizadas"
  value       = var.availability_zones
}

# OUTPUTS DE INFORMACIÓN GENERAL

output "vpc_endpoints_enabled" {
  description = "Mapa de VPC Endpoints habilitados"
  value = {
    s3              = var.enable_s3_vpc_endpoint
    dynamodb        = var.enable_dynamodb_vpc_endpoint
    sqs             = var.enable_sqs_vpc_endpoint
    sns             = var.enable_sns_vpc_endpoint
    ecr             = var.enable_ecr_vpc_endpoint
    secretsmanager  = var.enable_secretsmanager_vpc_endpoint
    cloudwatch      = var.enable_cloudwatch_vpc_endpoint
    opensearch      = var.enable_opensearch_vpc_endpoint
    elasticache     = var.enable_elasticache_vpc_endpoint
    ecs             = var.enable_ecs_vpc_endpoint
  }
}

output "security_groups_summary" {
  description = "Resumen de Security Groups creados"
  value = {
    alb           = aws_security_group.alb.id
    ecs           = aws_security_group.ecs.id
    rds           = var.create_rds_security_group ? aws_security_group.rds[0].id : "not_created"
    redis         = var.create_redis_security_group ? aws_security_group.redis[0].id : "not_created"
    opensearch    = var.create_opensearch_security_group ? aws_security_group.opensearch[0].id : "not_created"
    vpc_endpoints = var.enable_vpc_endpoints_security_group ? aws_security_group.vpc_endpoints[0].id : "not_created"
  }
}