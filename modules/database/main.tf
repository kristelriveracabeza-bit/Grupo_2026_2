# DATA SOURCES
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_vpc" "this" {
  id = var.vpc_id
}

# SUFFIX RANDOM PARA RECURSOS ÚNICOS
resource "random_id" "suffix" {
  byte_length = 4
}


# 1. DYNAMODB TABLES


# Tabla: Citas (Appointments) - Almacena todas las citas médicas
resource "aws_dynamodb_table" "appointments" {
  name           = "${var.project_name}-appointments-${var.environment}"
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "appointment_id"

  # Clave primaria - ID único de la cita
  attribute {
    name = "appointment_id"
    type = "S"
  }

  # ID del paciente asociado a la cita (Requerido por PatientIndex)
  attribute {
    name = "patient_id"
    type = "S"
  }

  # ID del doctor asignado a la cita (Requerido por DoctorIndex)
  attribute {
    name = "doctor_id"
    type = "S"
  }

  # Fecha y hora de la cita (Requerido como range_key en GSIs)
  attribute {
    name = "appointment_date"
    type = "S"
  }

  # Estado de la cita: scheduled, completed, etc. (Requerido por StatusIndex)
  attribute {
    name = "status"
    type = "S"
  }

  # GSI para buscar citas por paciente y fecha
  global_secondary_index {
    name            = "PatientIndex"
    hash_key        = "patient_id"
    range_key       = "appointment_date"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  # GSI para buscar citas por doctor y fecha
  global_secondary_index {
    name            = "DoctorIndex"
    hash_key        = "doctor_id"
    range_key       = "appointment_date"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  # GSI para buscar citas por estado y fecha
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "appointment_date"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = var.enable_ttl
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-appointments-${var.environment}"
    Environment = var.environment
  })
}

# Tabla: Pacientes (Patients) - Almacena información de los pacientes
resource "aws_dynamodb_table" "patients" {
  name           = "${var.project_name}-patients-${var.environment}"
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "patient_id"

  attribute {
    name = "patient_id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "phone"
    type = "S"
  }

  # GSI para buscar pacientes por email
  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  # GSI para buscar pacientes por teléfono
  global_secondary_index {
    name            = "PhoneIndex"
    hash_key        = "phone"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-patients-${var.environment}"
    Environment = var.environment
  })
}

# Tabla: Doctores (Doctors) - Almacena información de los médicos
resource "aws_dynamodb_table" "doctors" {
  name           = "${var.project_name}-doctors-${var.environment}"
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "doctor_id"

  attribute {
    name = "doctor_id"
    type = "S"
  }

  attribute {
    name = "specialty"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  # GSI para buscar doctores por specialty
  global_secondary_index {
    name            = "SpecialtyIndex"
    hash_key        = "specialty"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  # GSI para buscar doctores por email
  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-doctors-${var.environment}"
    Environment = var.environment
  })
}

# Tabla: Historial de citas (Appointment History)
resource "aws_dynamodb_table" "appointment_history" {
  name           = "${var.project_name}-appointment-history-${var.environment}"
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "history_id"

  attribute {
    name = "history_id"
    type = "S"
  }

  attribute {
    name = "appointment_id"
    type = "S"
  }

  attribute {
    name = "action_date"
    type = "S"
  }

  attribute {
    name = "action_type"
    type = "S"
  }

  # GSI para ver historial por cita
  global_secondary_index {
    name            = "AppointmentActionIndex"
    hash_key        = "appointment_id"
    range_key       = "action_date"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  # GSI para buscar acciones por tipo
  global_secondary_index {
    name            = "ActionTypeIndex"
    hash_key        = "action_type"
    range_key       = "action_date"
    projection_type = "ALL"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-appointment-history-${var.environment}"
    Environment = var.environment
  })
}


# ALMACENAMIENTO S3 PARA ARCHIVOS


resource "aws_s3_bucket" "data_storage" {
  bucket        = "${var.project_name}-data-storage-${var.environment}-${random_id.suffix.hex}"
  force_destroy = var.environment == "prod" ? false : true

  tags = merge(var.tags, {
    Name        = "${var.project_name}-data-storage-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.data_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_encryption" {
  bucket = aws_s3_bucket.data_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage_public_access" {
  bucket = aws_s3_bucket.data_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "storage_https" {
  bucket = aws_s3_bucket.data_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "ForceHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.data_storage.arn,
          "${aws_s3_bucket.data_storage.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "storage_lifecycle" {
  bucket = aws_s3_bucket.data_storage.id

  rule {
    id     = "archive-old-files"
    status = "Enabled"

    filter {}

    transition {
      days          = var.s3_transition_days
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.s3_noncurrent_version_expiration_days
    }
  }
}

resource "aws_s3_object" "uploads_folder" {
  bucket  = aws_s3_bucket.data_storage.id
  key     = "uploads/"
  content = ""
}

resource "aws_s3_object" "processed_folder" {
  bucket  = aws_s3_bucket.data_storage.id
  key     = "processed/"
  content = ""
}

resource "aws_s3_object" "temp_folder" {
  bucket  = aws_s3_bucket.data_storage.id
  key     = "temp/"
  content = ""
}

# 2. ELASTICACHE (REDIS) PARA CACHÉ DE HORARIOS


resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.project_name}-redis-subnet-${var.environment}"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for ElastiCache Redis"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-redis-subnet-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg-${var.environment}"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis port from application"
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = var.application_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-redis-sg-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_log_group" "redis_logs" {
  name              = "/aws/elasticache/${var.project_name}-redis-${var.environment}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-redis-logs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis-${var.environment}"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  parameter_group_name = "default.redis7"
  port                 = var.redis_port
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  snapshot_retention_limit = var.redis_snapshot_retention_days
  snapshot_window          = var.redis_snapshot_window

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-redis-${var.environment}"
    Environment = var.environment
  })
}


# 3. OPENSEARCH SERVICE PARA BÚSQUEDA DE DOCTORES


resource "aws_cloudwatch_log_group" "opensearch_logs" {
  name              = "/aws/opensearch/${var.project_name}-doctors-${var.environment}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-opensearch-logs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_policy" {
  policy_name = "${var.project_name}-opensearch-log-policy-${var.environment}"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.opensearch_logs.arn}:*"
      }
    ]
  })
}

resource "aws_security_group" "opensearch" {
  name        = "${var.project_name}-opensearch-sg-${var.environment}"
  description = "Security group for OpenSearch"
  vpc_id      = var.vpc_id

  ingress {
    description     = "OpenSearch port from application"
    from_port       = var.opensearch_port
    to_port         = var.opensearch_port
    protocol        = "tcp"
    security_groups = var.application_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-opensearch-sg-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_opensearch_domain" "doctors_search" {
  domain_name    = "${var.project_name}-doctors-${var.environment}"
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type            = var.opensearch_instance_type
    instance_count           = var.opensearch_instance_count
    zone_awareness_enabled   = var.opensearch_zone_awareness
    dedicated_master_enabled = var.opensearch_dedicated_master_enabled
    dedicated_master_type    = var.opensearch_dedicated_master_type
    dedicated_master_count   = var.opensearch_dedicated_master_count
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.opensearch_volume_size
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "AUDIT_LOGS"
    enabled                  = true
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
    enabled                  = true
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
    enabled                  = true
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.opensearch_master_user
      master_user_password = var.opensearch_master_password
    }
  }

  vpc_options {
    security_group_ids = [aws_security_group.opensearch.id]
    subnet_ids         = [var.private_subnet_ids[0]] # Mapeado a un ID válido de lista
  }

  snapshot_options {
    automated_snapshot_start_hour = var.opensearch_snapshot_hour
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-doctors-search-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_opensearch_domain_policy" "doctors_search" {
  domain_name = aws_opensearch_domain.doctors_search.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.application_role_arn
        }
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete",
          "es:ESHttpHead"
        ]
        Resource = "${aws_opensearch_domain.doctors_search.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "es:ESHttp*"
        Resource = "${aws_opensearch_domain.doctors_search.arn}/*"
        Condition = {
          "IpAddress" = {
            "aws:SourceIp" = var.allowed_cidr_blocks
          }
        }
      }
    ]
  })
}

# VPC ENDPOINTS 


resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(var.tags, {
    Name        = "${var.project_name}-s3-endpoint-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(var.tags, {
    Name        = "${var.project_name}-dynamodb-endpoint-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "opensearch" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.es"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.opensearch.id]

  tags = merge(var.tags, {
    Name        = "${var.project_name}-opensearch-endpoint-${var.environment}"
    Environment = var.environment
  })
}


# CLOUDWATCH ALARMS


resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled" {
  count = var.enable_db_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-dynamodb-throttled-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dynamodb_throttle_alarm_threshold
  alarm_description   = "Alarma cuando hay throttling en DynamoDB"

  dimensions = {
    TableName = aws_dynamodb_table.appointments.name
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-dynamodb-throttled-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  count = var.enable_db_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-redis-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = var.redis_cpu_alarm_threshold
  alarm_description   = "Alarma cuando la CPU de Redis supera el umbral"

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.redis.cluster_id
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-redis-cpu-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "opensearch_cpu" {
  count = var.enable_db_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-opensearch-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = 300
  statistic           = "Average"
  threshold           = var.opensearch_cpu_alarm_threshold
  alarm_description   = "Alarma cuando la CPU de OpenSearch supera el umbral"

  dimensions = {
    DomainName = aws_opensearch_domain.doctors_search.domain_name
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-opensearch-cpu-${var.environment}"
    Environment = var.environment
  })
}


# SECRETS MANAGER


resource "aws_secretsmanager_secret" "db_credentials" {
  count = var.create_db_secret ? 1 : 0

  name                    = "${var.project_name}-db-credentials-${var.environment}"
  description             = "Credenciales de la base de datos para la aplicación"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name                    = "${var.project_name}-db-credentials-${var.environment}"
    Environment             = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count = var.create_db_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    dynamodb = {
      table_names = {
        appointments        = aws_dynamodb_table.appointments.name
        patients            = aws_dynamodb_table.patients.name
        doctors             = aws_dynamodb_table.doctors.name
        appointment_history = aws_dynamodb_table.appointment_history.name
      }
    }
    redis = {
      endpoint = aws_elasticache_cluster.redis.cache_nodes[0].address
      port     = var.redis_port
    }
    opensearch = {
      endpoint = aws_opensearch_domain.doctors_search.endpoint
      port     = var.opensearch_port
    }
    s3_bucket  = aws_s3_bucket.data_storage.id
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
  })
}


# IAM POLICIES


resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.project_name}-dynamodb-access-${var.environment}"
  description = "Política para acceso a tablas DynamoDB del proyecto"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          aws_dynamodb_table.appointments.arn,
          "${aws_dynamodb_table.appointments.arn}/*",
          aws_dynamodb_table.patients.arn,
          "${aws_dynamodb_table.patients.arn}/*",
          aws_dynamodb_table.doctors.arn,
          "${aws_dynamodb_table.doctors.arn}/*",
          aws_dynamodb_table.appointment_history.arn,
          "${aws_dynamodb_table.appointment_history.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBGSIAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "${aws_dynamodb_table.appointments.arn}/index/PatientIndex",
          "${aws_dynamodb_table.appointments.arn}/index/DoctorIndex",
          "${aws_dynamodb_table.appointments.arn}/index/StatusIndex",
          "${aws_dynamodb_table.patients.arn}/index/EmailIndex",
          "${aws_dynamodb_table.patients.arn}/index/PhoneIndex",
          "${aws_dynamodb_table.doctors.arn}/index/SpecialtyIndex",
          "${aws_dynamodb_table.doctors.arn}/index/EmailIndex",
          "${aws_dynamodb_table.appointment_history.arn}/index/AppointmentActionIndex",
          "${aws_dynamodb_table.appointment_history.arn}/index/ActionTypeIndex"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.project_name}-dynamodb-access-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-s3-access-${var.environment}"
  description = "Política para acceso al bucket S3 del proyecto"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.data_storage.arn,
          "${aws_s3_bucket.data_storage.arn}/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.project_name}-s3-access-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_iam_policy" "elasticache_access" {
  name        = "${var.project_name}-elasticache-access-${var.environment}"
  description = "Política para acceso a ElastiCache Redis"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ElastiCacheAccess"
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:DescribeCacheSubnetGroups"
        ]
        Resource = "arn:aws:elasticache:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster:${var.project_name}-redis-${var.environment}"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.project_name}-elasticache-access-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_iam_policy" "opensearch_access" {
  name        = "${var.project_name}-opensearch-access-${var.environment}"
  description = "Política para acceso a OpenSearch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OpenSearchAccess"
        Effect = "Allow"
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete"
        ]
        Resource = "${aws_opensearch_domain.doctors_search.arn}/*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.project_name}-opensearch-access-${var.environment}"
    Environment = var.environment
  })
}
# CKV2_AWS_57 — Los secrets en Secrets Manager no rotan automáticamente. Si una credencial se filtra, permanece válida indefinidamente hasta que alguien la cambie a mano.
