
# DATA SOURCES & LOCAL HEALPERS


data "aws_region" "current" {}

data "aws_route53_zone" "main" {
  count        = var.create_route53_records ? 1 : 0
  name         = var.route53_domain_name
  private_zone = false
}

locals {
  # Determina si se requiere el Security Group de VPC Endpoints de forma condicional
  enable_vpce_sg = var.enable_vpc_endpoints_security_group && (
    var.enable_sqs_vpc_endpoint || var.enable_sns_vpc_endpoint || 
    var.enable_ecr_vpc_endpoint || var.enable_secretsmanager_vpc_endpoint || 
    var.enable_cloudwatch_vpc_endpoint || var.enable_opensearch_vpc_endpoint || 
    var.enable_elasticache_vpc_endpoint || var.enable_ecs_vpc_endpoint
  )
  vpce_sg_ids = local.enable_vpce_sg ? [aws_security_group.vpc_endpoints[0].id] : []
}


# CAPA DE RED CORE (VPC, INTERNET GATEWAY & SUBNETS)


resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpc-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-igw-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-subnet-public-${count.index + 1}-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-subnet-private-${count.index + 1}-${var.environment}"
    Environment = var.environment
  })
}


# CONTROL DE ACCESO DE RED PERIMETRAL (NACLs)

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-nacl-public-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-nacl-private-${var.environment}"
    Environment = var.environment
  })
}


# ENRUTAMIENTO, NAT GATEWAY Y ARQUITECTURA ALTA DISPONIBILIDAD


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-rt-public-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-nat-eip-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-nat-gw-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[0].id
    }
  }

  dynamic "route" {
    for_each = !var.enable_nat_gateway ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this.id
    }
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-rt-private-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# CONTROL DE ACCESO PERIMETRAL: SECURITY GROUPS (DESACOPLADOS)


# ALB SECURITY GROUP
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg-${var.environment}"
  vpc_id      = aws_vpc.this.id
  description = "Permite trafico HTTP y HTTPS desde internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP desde internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS desde internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Todo el trafico saliente seguro"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-alb-sg-${var.environment}"
    Environment = var.environment
  })
}

# ECS SECURITY GROUP
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg-${var.environment}"
  vpc_id      = aws_vpc.this.id
  description = "Permite trafico desde el ALB y servicios internos"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Trafico desde el ALB"
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Trafico desde el ALB (puerto alternativo)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Requerido para descarga de imágenes de ECR y APIs públicas externas
    description = "Todo el trafico saliente"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-sg-${var.environment}"
    Environment = var.environment
  })
}

# RDS SECURITY GROUP
resource "aws_security_group" "rds" {
  count       = var.create_rds_security_group ? 1 : 0
  name        = "${var.project_name}-rds-sg-${var.environment}"
  vpc_id      = aws_vpc.this.id
  description = "Security group para recursos de base de datos"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "MySQL/Aurora desde ECS"
  }

  dynamic "ingress" {
    for_each = var.allowed_admin_cidrs
    content {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Acceso administrativo desde IPs autorizadas"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # CKV_AWS_382: Restringido estrictamente a la VPC interna
    description = "Salida limitada a la red interna corporativa"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-rds-sg-${var.environment}"
    Environment = var.environment
  })
}

# REDIS SECURITY GROUP
resource "aws_security_group" "redis" {
  count       = var.create_redis_security_group ? 1 : 0
  name        = "${var.project_name}-redis-sg-${var.environment}"
  vpc_id      = aws_vpc.this.id
  description = "Security group para ElastiCache Redis"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "Redis desde ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # CKV_AWS_382 Corrección
    description = "Salida limitada a la red interna"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-redis-sg-${var.environment}"
    Environment = var.environment
  })
}

# OPENSEARCH SECURITY GROUP
resource "aws_security_group" "opensearch" {
  count       = var.create_opensearch_security_group ? 1 : 0
  name        = "${var.project_name}-opensearch-sg-${var.environment}"
  vpc_id      = aws_vpc.this.id
  description = "Security group para OpenSearch"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "OpenSearch desde ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # CKV_AWS_382 Corrección
    description = "Salida limitada"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-opensearch-sg-${var.environment}"
    Environment = var.environment
  })
}

# VPC ENDPOINTS SECURITY GROUP
resource "aws_security_group" "vpc_endpoints" {
  count       = local.enable_vpce_sg ? 1 : 0
  name        = "${var.project_name}-vpce-sg-${var.environment}"
  vpc_id      = aws_vpc.this.id
  description = "Security group para VPC Endpoints"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # CKV_AWS_382 Corrección
    description = "Todo el trafico saliente limitado a la red interna"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-sg-${var.environment}"
    Environment = var.environment
  })
}

# REGLAS COMPLEMENTARIAS INDEPENDIENTES (Evitan la dependencia cíclica entre ECS, Redis y Endpoints)
resource "aws_security_group_rule" "vpce_ingress_from_ecs" {
  count                    = local.enable_vpce_sg ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints[0].id
  source_security_group_id = aws_security_group.ecs.id
  description              = "HTTPS desde ECS a los VPC Endpoints"
}

resource "aws_security_group_rule" "ecs_ingress_from_redis" {
  count                    = var.create_redis_security_group ? 1 : 0
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.redis[0].id
  description              = "Entrada de Redis desde ElastiCache a los contenedores"
}


# CONECTIVIDAD PRIVADA SOBERANA (VPC ENDPOINTS GATEWAY & INTERFACE)


resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_vpc_endpoint ? 1 : 0
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private.id
  ]

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-s3-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count        = var.enable_dynamodb_vpc_endpoint ? 1 : 0
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private.id
  ]

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-dynamodb-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "sqs" {
  count               = var.enable_sqs_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-sqs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "sns" {
  count               = var.enable_sns_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-sns-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.enable_ecr_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-ecr-api-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.enable_ecr_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-ecr-dkr-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.enable_secretsmanager_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-secretsmanager-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count               = var.enable_cloudwatch_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-cloudwatch-logs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "cloudwatch_monitoring" {
  count               = var.enable_cloudwatch_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-cloudwatch-monitoring-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "opensearch" {
  count               = var.enable_opensearch_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.es"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-opensearch-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "elasticache" {
  count               = var.enable_elasticache_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.elasticache"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-elasticache-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "ecs" {
  count               = var.enable_ecs_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-ecs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "ecs_agent" {
  count               = var.enable_ecs_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-ecs-agent-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  count               = var.enable_ecs_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = local.vpce_sg_ids
  private_dns_enabled = true

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpce-ecs-telemetry-${var.environment}"
    Environment = var.environment
  })
}


# ENRUTAMIENTO DNS INTERNO AUTOMATIZADO (AWS CLOUD MAP)


resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.cloud_map_namespace
  vpc         = aws_vpc.this.id
  description = "Cloud Map namespace para microservicios de ${var.project_name}"

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-cloudmap-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_service_discovery_service" "appointments" {
  name = "appointments"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-cloudmap-appointments-${var.environment}"
    Environment = var.environment
    Service     = "appointments"
  })
}

resource "aws_service_discovery_service" "patients" {
  name = "patients"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-cloudmap-patients-${var.environment}"
    Environment = var.environment
    Service     = "patients"
  })
}


# RESOLUCIÓN PÚBLICA DE DOMINIOS (ROUTE 53)


resource "aws_route53_record" "alb" {
  count = var.create_route53_records ? 1 : 0

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.alb_subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}


# AUDITORÍA DE RED GENERAL (VPC FLOW LOGS & SEGURIDAD)


resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.project_name}-flow-logs-${var.environment}"
  retention_in_days = var.vpc_flow_logs_retention

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-flow-logs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.project_name}-vpc-flow-logs-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpc-flow-logs-role-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.project_name}-vpc-flow-logs-policy-${var.environment}"
  role  = aws_iam_role.vpc_flow_logs[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  count           = var.enable_vpc_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpc-flow-log-${var.environment}"
    Environment = var.environment
  })
}
# CKV_AWS_382  Los security groups permiten todo el tráfico saliente sin restricción. Si no se corrige, cualquier proceso comprometido dentro del servidor puede conectarse a cualquier destino en internet.
# CKV_AWS_158 — El grupo de logs de CloudWatch no está cifrado con KMS. Si alguien accede al almacenamiento de AWS, puede leer los logs en texto plano.
# CKV2_AWS_61 — Los buckets S3 no tienen reglas de ciclo de vida. Los archivos se acumulan indefinidamente, aumentando el costo de almacenamiento sin control.
# CKV2_AWS_62 — Los buckets S3 no notifican cuando se crea o modifica un objeto. No hay forma automática de detectar actividad sospechosa o iniciar procesos al llegar nuevos archivos.
# CKV2_AWS_19 — La IP elástica (EIP) no está asociada a una instancia EC2. Checkov lo marca como error, pero en este caso es un falso positivo porque el EIP es para el NAT Gateway.
# CKV_AWS_18 — Los buckets S3 no tienen logging de acceso. No hay registro de quién descargó, borró o modificó archivos.
# CKV2_AWS_76 — El WAF del ALB no tiene activada la regla contra Log4j. Un atacante puede explotar la vulnerabilidad Log4Shell directamente contra la aplicación.
# CKV2_AWS_5 — Checkov detecta security groups sin recursos asociados visibles. Es un falso positivo porque los SGs se usan en otros módulos que Checkov no puede ver desde aquí.
# CKV2_AWS_6 — Los buckets S3 no tienen bloqueado el acceso público. Un error de configuración futuro podría exponer los logs de WAF a internet.
# CKV2_AWS_12 — El security group por defecto del VPC no tiene reglas restrictivas. Si algún recurso queda asociado a ese SG por accidente, tendría tráfico abierto.
# CKV_AWS_145 — Los buckets S3 no usan cifrado KMS, solo el cifrado por defecto de AWS. Sin KMS propio, no puedes revocar el acceso a los datos deshabilitando la clave.
# CKV_AWS_144 — Los buckets S3 no tienen replicación en otra región. Si la región principal falla o los datos se corrompen, no hay copia de respaldo.
# CKV_AWS_21 — Los buckets S3 no tienen versionado activado. Si se sobreescribe o borra un archivo por error, no se puede recuperar la versión anterior.


