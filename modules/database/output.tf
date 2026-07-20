
# OUTPUTS DE DYNAMODB


output "dynamodb_appointments_table_name" {
  description = "Nombre de la tabla DynamoDB de citas"
  value       = aws_dynamodb_table.appointments.name
}

output "dynamodb_appointments_table_arn" {
  description = "ARN de la tabla DynamoDB de citas"
  value       = aws_dynamodb_table.appointments.arn
}

output "dynamodb_patients_table_name" {
  description = "Nombre de la tabla DynamoDB de pacientes"
  value       = aws_dynamodb_table.patients.name
}

output "dynamodb_patients_table_arn" {
  description = "ARN de la tabla DynamoDB de pacientes"
  value       = aws_dynamodb_table.patients.arn
}

output "dynamodb_doctors_table_name" {
  description = "Nombre de la tabla DynamoDB de doctores"
  value       = aws_dynamodb_table.doctors.name
}

output "dynamodb_doctors_table_arn" {
  description = "ARN de la tabla DynamoDB de doctores"
  value       = aws_dynamodb_table.doctors.arn
}

output "dynamodb_appointment_history_table_name" {
  description = "Nombre de la tabla DynamoDB de historial de citas"
  value       = aws_dynamodb_table.appointment_history.name
}

output "dynamodb_appointment_history_table_arn" {
  description = "ARN de la tabla DynamoDB de historial de citas"
  value       = aws_dynamodb_table.appointment_history.arn
}

output "dynamodb_table_names" {
  description = "Mapa con todos los nombres de las tablas DynamoDB"
  value = {
    appointments        = aws_dynamodb_table.appointments.name
    patients            = aws_dynamodb_table.patients.name
    doctors             = aws_dynamodb_table.doctors.name
    appointment_history = aws_dynamodb_table.appointment_history.name
  }
}

output "dynamodb_table_arns" {
  description = "Mapa con todos los ARNs de las tablas DynamoDB"
  value = {
    appointments        = aws_dynamodb_table.appointments.arn
    patients            = aws_dynamodb_table.patients.arn
    doctors             = aws_dynamodb_table.doctors.arn
    appointment_history = aws_dynamodb_table.appointment_history.arn
  }
}


# OUTPUTS DE ELASTICACHE (REDIS)


output "redis_endpoint" {
  description = "Endpoint de conexión para Redis"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Puerto de conexión para Redis"
  value       = var.redis_port
}

output "redis_security_group_id" {
  description = "ID del security group de Redis"
  value       = aws_security_group.redis.id
}

output "redis_security_group_arn" {
  description = "ARN del security group de Redis"
  value       = aws_security_group.redis.arn
}

output "redis_subnet_group_name" {
  description = "Nombre del subnet group de Redis"
  value       = aws_elasticache_subnet_group.redis.name
}

output "redis_cache_name" {
  description = "Nombre del cache Redis"
  value       = aws_elasticache_cluster.redis.cluster_id
}

output "redis_cache_arn" {
  description = "ARN del cache Redis"
  value       = aws_elasticache_cluster.redis.arn
}

output "redis_connection_string" {
  description = "Cadena de conexión completa para Redis"
  value       = "${aws_elasticache_cluster.redis.cache_nodes[0].address}:${var.redis_port}"
}


# OUTPUTS DE OPENSEARCH


output "opensearch_endpoint" {
  description = "Endpoint de conexión para OpenSearch"
  value       = aws_opensearch_domain.doctors_search.endpoint
}

output "opensearch_domain_id" {
  description = "ID del dominio OpenSearch"
  value       = aws_opensearch_domain.doctors_search.domain_id
}

output "opensearch_domain_name" {
  description = "Nombre del dominio OpenSearch"
  value       = aws_opensearch_domain.doctors_search.domain_name
}

output "opensearch_arn" {
  description = "ARN del dominio OpenSearch"
  value       = aws_opensearch_domain.doctors_search.arn
}

output "opensearch_security_group_id" {
  description = "ID del security group de OpenSearch"
  value       = aws_security_group.opensearch.id
}

output "opensearch_security_group_arn" {
  description = "ARN del security group de OpenSearch"
  value       = aws_security_group.opensearch.arn
}

output "opensearch_dashboard_endpoint" {
  description = "Endpoint del dashboard de OpenSearch"
  value       = aws_opensearch_domain.doctors_search.dashboard_endpoint
}


# OUTPUTS DE S3


output "s3_bucket_id" {
  description = "ID del bucket S3"
  value       = aws_s3_bucket.data_storage.id
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.data_storage.arn
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.data_storage.bucket
}

output "s3_bucket_domain_name" {
  description = "Nombre de dominio del bucket S3"
  value       = aws_s3_bucket.data_storage.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Nombre de dominio regional del bucket S3"
  value       = aws_s3_bucket.data_storage.bucket_regional_domain_name
}

output "s3_uploads_folder" {
  description = "Ruta de la carpeta uploads en S3"
  value       = "s3://${aws_s3_bucket.data_storage.bucket}/uploads/"
}

output "s3_processed_folder" {
  description = "Ruta de la carpeta processed en S3"
  value       = "s3://${aws_s3_bucket.data_storage.bucket}/processed/"
}

output "s3_temp_folder" {
  description = "Ruta de la carpeta temp en S3"
  value       = "s3://${aws_s3_bucket.data_storage.bucket}/temp/"
}


# OUTPUTS DE VPC ENDPOINTS


output "vpc_endpoint_s3_id" {
  description = "ID del VPC endpoint para S3"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_dynamodb_id" {
  description = "ID del VPC endpoint para DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "vpc_endpoint_opensearch_id" {
  description = "ID del VPC endpoint para OpenSearch"
  value       = aws_vpc_endpoint.opensearch.id
}


# OUTPUTS DE CLOUDWATCH ALARMS


output "cloudwatch_alarm_dynamodb_throttled_name" {
  description = "Nombre de la alarma de CloudWatch para DynamoDB throttled"
  value       = try(aws_cloudwatch_metric_alarm.dynamodb_throttled[0].alarm_name, null)
}

output "cloudwatch_alarm_redis_cpu_name" {
  description = "Nombre de la alarma de CloudWatch para CPU de Redis"
  value       = try(aws_cloudwatch_metric_alarm.redis_cpu[0].alarm_name, null)
}

output "cloudwatch_alarm_opensearch_cpu_name" {
  description = "Nombre de la alarma de CloudWatch para CPU de OpenSearch"
  value       = try(aws_cloudwatch_metric_alarm.opensearch_cpu[0].alarm_name, null)
}


# OUTPUTS DE SECRETS MANAGER


output "secrets_manager_secret_id" {
  description = "ID del secreto en Secrets Manager"
  value       = try(aws_secretsmanager_secret.db_credentials[0].id, null)
}

output "secrets_manager_secret_arn" {
  description = "ARN del secreto en Secrets Manager"
  value       = try(aws_secretsmanager_secret.db_credentials[0].arn, null)
}

output "secrets_manager_secret_name" {
  description = "Nombre del secreto en Secrets Manager"
  value       = try(aws_secretsmanager_secret.db_credentials[0].name, null)
}


# OUTPUTS DE IAM POLICIES


output "iam_policy_dynamodb_access_name" {
  description = "Nombre de la política IAM para acceso a DynamoDB"
  value       = aws_iam_policy.dynamodb_access.name
}

output "iam_policy_dynamodb_access_arn" {
  description = "ARN de la política IAM para acceso a DynamoDB"
  value       = aws_iam_policy.dynamodb_access.arn
}

output "iam_policy_s3_access_name" {
  description = "Nombre de la política IAM para acceso a S3"
  value       = aws_iam_policy.s3_access.name
}

output "iam_policy_s3_access_arn" {
  description = "ARN de la política IAM para acceso a S3"
  value       = aws_iam_policy.s3_access.arn
}

output "iam_policy_elasticache_access_name" {
  description = "Nombre de la política IAM para acceso a ElastiCache"
  value       = aws_iam_policy.elasticache_access.name
}

output "iam_policy_elasticache_access_arn" {
  description = "ARN de la política IAM para acceso a ElastiCache"
  value       = aws_iam_policy.elasticache_access.arn
}

output "iam_policy_opensearch_access_name" {
  description = "Nombre de la política IAM para acceso a OpenSearch"
  value       = aws_iam_policy.opensearch_access.name
}

output "iam_policy_opensearch_access_arn" {
  description = "ARN de la política IAM para acceso a OpenSearch"
  value       = aws_iam_policy.opensearch_access.arn
}

output "iam_policy_names" {
  description = "Mapa con todos los nombres de las políticas IAM"
  value = {
    dynamodb_access    = aws_iam_policy.dynamodb_access.name
    s3_access          = aws_iam_policy.s3_access.name
    elasticache_access = aws_iam_policy.elasticache_access.name
    opensearch_access  = aws_iam_policy.opensearch_access.name
  }
}

output "iam_policy_arns" {
  description = "Mapa con todos los ARNs de las políticas IAM"
  value = {
    dynamodb_access    = aws_iam_policy.dynamodb_access.arn
    s3_access          = aws_iam_policy.s3_access.arn
    elasticache_access = aws_iam_policy.elasticache_access.arn
    opensearch_access  = aws_iam_policy.opensearch_access.arn
  }
}


# OUTPUTS DE INFORMACIÓN GENERAL


output "aws_region" {
  description = "Región de AWS donde se desplegaron los recursos"
  value       = data.aws_region.current.name
}

output "aws_account_id" {
  description = "ID de la cuenta de AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "suffix_random" {
  description = "Sufijo random generado para recursos únicos"
  value       = random_id.suffix.hex
}

output "module_name" {
  description = "Nombre del módulo"
  value       = "database"
}

output "resource_summary" {
  description = "Resumen de todos los recursos creados"
  value = {
    dynamodb_tables = {
      appointments        = aws_dynamodb_table.appointments.name
      patients            = aws_dynamodb_table.patients.name
      doctors             = aws_dynamodb_table.doctors.name
      appointment_history = aws_dynamodb_table.appointment_history.name
    }
    redis = {
      endpoint = aws_elasticache_cluster.redis.cache_nodes[0].address
      port     = var.redis_port
    }
    opensearch = {
      endpoint = aws_opensearch_domain.doctors_search.endpoint
      domain   = aws_opensearch_domain.doctors_search.domain_name
    }
    s3 = {
      bucket = aws_s3_bucket.data_storage.bucket
    }
    vpc_endpoints = {
      s3         = aws_vpc_endpoint.s3.id
      dynamodb   = aws_vpc_endpoint.dynamodb.id
      opensearch = aws_vpc_endpoint.opensearch.id
    }
  }
}
