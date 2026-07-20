
# VARIABLES GENERALES


variable "project_name" {
  description = "Nombre del proyecto para identificar recursos"
  type        = string
  default     = "dermatologia"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "El nombre del proyecto debe contener solo letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno de ejecución (dev/staging/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment debe ser dev, staging o prod."
  }
}


# VARIABLES DE VPC


variable "vpc_cidr" {
  description = "CIDR block para la VPC (ej: 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr debe ser un CIDR válido (ej: '10.0.0.0/16')"
  }
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidad (mínimo 2 para alta disponibilidad)"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Se requieren al menos 2 zonas de disponibilidad para alta disponibilidad."
  }
}


# VARIABLES DE SUBNETS


variable "public_subnets_cidr" {
  description = "CIDR blocks para las subredes públicas (debe coincidir con el número de AZs)"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets_cidr) == length(var.availability_zones)
    error_message = "El número de subredes públicas debe coincidir con el número de AZs."
  }

  validation {
    condition = alltrue([
      for cidr in var.public_subnets_cidr : can(cidrhost(cidr, 0))
    ])
    error_message = "Cada CIDR de subred pública debe ser válido."
  }
}

variable "private_subnets_cidr" {
  description = "CIDR blocks para las subredes privadas (debe coincidir con el número de AZs)"
  type        = list(string)

  validation {
    condition     = length(var.private_subnets_cidr) == length(var.availability_zones)
    error_message = "El número de subredes privadas debe coincidir con el número de AZs."
  }

  validation {
    condition = alltrue([
      for cidr in var.private_subnets_cidr : can(cidrhost(cidr, 0))
    ])
    error_message = "Cada CIDR de subred privada debe ser válido."
  }
}


# VARIABLES DE NAT GATEWAY


variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para salida a internet desde subredes privadas"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar un solo NAT Gateway (ahorro de costos, menos HA)"
  type        = bool
  default     = true
}


# VARIABLES DE SEGURIDAD


variable "allowed_admin_cidrs" {
  description = "CIDRs permitidos para acceso administrativo a la base de datos"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.allowed_admin_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Cada CIDR en allowed_admin_cidrs debe ser válido."
  }
}


# VARIABLES DE VPC FLOW LOGS


variable "enable_vpc_flow_logs" {
  description = "Habilitar VPC Flow Logs para auditoría de tráfico"
  type        = bool
  default     = true
}

variable "vpc_flow_logs_retention" {
  description = "Días de retención para VPC Flow Logs"
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.vpc_flow_logs_retention)
    error_message = "vpc_flow_logs_retention debe ser un valor válido para CloudWatch Logs."
  }
}


# VARIABLES DE TAGS


variable "additional_tags" {
  description = "Tags adicionales para todos los recursos de networking"
  type        = map(string)
  default     = {}
}


# VARIABLES DE VPC ENDPOINTS (GATEWAY)


variable "enable_s3_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para S3"
  type        = bool
  default     = true
}

variable "enable_dynamodb_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para DynamoDB"
  type        = bool
  default     = true
}


# VARIABLES DE VPC ENDPOINTS (INTERFACE)


variable "enable_sqs_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para SQS"
  type        = bool
  default     = true
}

variable "enable_sns_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para SNS"
  type        = bool
  default     = true
}

variable "enable_ecr_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para ECR (necesario para ECS)"
  type        = bool
  default     = true
}

variable "enable_secretsmanager_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para Secrets Manager"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para CloudWatch Logs y Monitoring"
  type        = bool
  default     = true
}

variable "enable_opensearch_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para OpenSearch"
  type        = bool
  default     = true
}

variable "enable_elasticache_vpc_endpoint" {
  description = "Habilitar VPC Endpoint para ElastiCache"
  type        = bool
  default     = true
}

variable "enable_ecs_vpc_endpoint" {
  description = "Habilitar VPC Endpoints para ECS (API, Agent, Telemetry)"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints_security_group" {
  description = "Crear Security Group específico para VPC Endpoints"
  type        = bool
  default     = true
}


# VARIABLES DE DHCP


variable "enable_dhcp_options" {
  description = "Habilitar opciones DHCP personalizadas"
  type        = bool
  default     = false
}

variable "domain_name_servers" {
  description = "Servidores DNS personalizados (solo si enable_dhcp_options es true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]

  validation {
    condition = alltrue([
      for dns in var.domain_name_servers : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$|^[a-zA-Z0-9.-]+$", dns))
    ])
    error_message = "Cada servidor DNS debe ser una dirección IP válida o un nombre de dominio estructurado correctamente."
  }
}


# VARIABLES DE AWS CLOUD MAP


variable "cloud_map_namespace" {
  description = "Nombre del namespace de Cloud Map para descubrimiento de servicios"
  type        = string
  default     = "dermatologia.local"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+$", var.cloud_map_namespace))
    error_message = "El namespace de Cloud Map solo puede contener letras, números, puntos y guiones."
  }
}


# VARIABLES DE ROUTE 53


variable "route53_domain_name" {
  description = "Nombre del dominio en Route 53 (ej: dermatologia.com)"
  type        = string
  default     = "dermatologia.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.route53_domain_name))
    error_message = "El dominio debe ser válido (ej: ejemplo.com)."
  }
}

variable "create_route53_records" {
  description = "Crear registros en Route 53 para el ALB"
  type        = bool
  default     = false
}

variable "alb_subdomain" {
  description = "Subdominio para el ALB (ej: app.dermatologia.com)"
  type        = string
  default     = "app"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.alb_subdomain))
    error_message = "El subdominio solo puede contener letras, números y guiones."
  }
}

variable "alb_dns_name" {
  description = "DNS name del ALB (se debe pasar desde el módulo de loadbalancer)"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Zone ID del ALB (se debe pasar desde el módulo de loadbalancer)"
  type        = string
  default     = ""
}


# VARIABLES PARA SECURITY GROUPS


variable "create_rds_security_group" {
  description = "Crear Security Group para RDS/Aurora (opcional si usas DynamoDB)"
  type        = bool
  default     = false
}

variable "create_redis_security_group" {
  description = "Crear Security Group para Redis (ElastiCache)"
  type        = bool
  default     = true
}

variable "create_opensearch_security_group" {
  description = "Crear Security Group para OpenSearch"
  type        = bool
  default     = true
}


# VARIABLES PARA DESPLIEGUE


variable "enable_vpn_gateway" {
  description = "Habilitar VPN Gateway para la VPC"
  type        = bool
  default     = false
}

variable "enable_flow_logs_s3" {
  description = "Enviar VPC Flow Logs a S3 en lugar de CloudWatch"
  type        = bool
  default     = false
}

variable "flow_logs_s3_bucket" {
  description = "Bucket S3 para VPC Flow Logs (si enable_flow_logs_s3 es true)"
  type        = string
  default     = ""
}


# VARIABLES PARA RESILIENCIA


variable "enable_az_affinity" {
  description = "Habilitar afinidad de zona para recursos (evita desbalanceo)"
  type        = bool
  default     = false
}

variable "preferred_azs" {
  description = "Lista de zonas de disponibilidad preferidas (solo si enable_az_affinity es true)"
  type        = list(string)
  default     = []
}
