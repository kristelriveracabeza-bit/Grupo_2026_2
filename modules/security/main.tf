
# DATA SOURCES


data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


# ROLES IAM PRINCIPALES


# ROL PARA LAMBDA
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-lambda-role-${var.environment}"
    Environment = var.environment
  })
}

# ROL PARA ECS TASK EXECUTION
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-task-execution-role-${var.environment}"
    Environment = var.environment
  })
}

# ROL PARA ECS TASK (Aplicación)
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-task-role-${var.environment}"
    Environment = var.environment
  })
}

# ROL PARA COGNITO
resource "aws_iam_role" "cognito" {
  name = "${var.project_name}-cognito-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cognito-idp.amazonaws.com" }
    }]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-cognito-role-${var.environment}"
    Environment = var.environment
  })
}


# POLÍTICAS PARA LAMBDA


# Política para SQS
resource "aws_iam_policy" "lambda_sqs" {
  name        = "${var.project_name}-lambda-sqs-${var.environment}"
  description = "Permisos para Lambda acceder a SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-lambda-sqs-${var.environment}"
    Environment = var.environment
  })
}

# Política para SNS
resource "aws_iam_policy" "lambda_sns" {
  name        = "${var.project_name}-lambda-sns-${var.environment}"
  description = "Permisos para Lambda publicar en SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-lambda-sns-${var.environment}"
    Environment = var.environment
  })
}

# Política para Secrets Manager
resource "aws_iam_policy" "lambda_secrets" {
  name        = "${var.project_name}-lambda-secrets-${var.environment}"
  description = "Permisos para Lambda acceder a Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_arn
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-lambda-secrets-${var.environment}"
    Environment = var.environment
  })
}

# Política para DynamoDB
resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${var.project_name}-lambda-dynamodb-${var.environment}"
  description = "Permisos para Lambda acceder a DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-lambda-dynamodb-${var.environment}"
    Environment = var.environment
  })
}

# Política para CloudWatch Logs 
resource "aws_iam_policy" "lambda_logs" {
  name        = "${var.project_name}-lambda-logs-${var.environment}"
  description = "Permisos para Lambda escribir en CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-lambda-logs-${var.environment}"
    Environment = var.environment
  })
}


# POLÍTICAS PARA ECS TASK EXECUTION


# Política para ECR 
resource "aws_iam_policy" "ecs_ecr" {
  name        = "${var.project_name}-ecs-ecr-${var.environment}"
  description = "Permisos para ECS descargar imágenes de ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = var.ecr_repository_arns
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-ecr-${var.environment}"
    Environment = var.environment
  })
}

# Política para CloudWatch Logs (ECS)
resource "aws_iam_policy" "ecs_logs" {
  name        = "${var.project_name}-ecs-logs-${var.environment}"
  description = "Permisos para ECS escribir en CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/*"
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-logs-${var.environment}"
    Environment = var.environment
  })
}


# POLÍTICAS PARA ECS TASK (Aplicación)


# Política para DynamoDB (ECS)
resource "aws_iam_policy" "ecs_dynamodb" {
  name        = "${var.project_name}-ecs-dynamodb-${var.environment}"
  description = "Permisos para ECS acceder a DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = var.dynamodb_table_arns
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-dynamodb-${var.environment}"
    Environment = var.environment
  })
}

# Política para S3 (ECS)
resource "aws_iam_policy" "ecs_s3" {
  name        = "${var.project_name}-ecs-s3-${var.environment}"
  description = "Permisos para ECS acceder a S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-s3-${var.environment}"
    Environment = var.environment
  })
}

# Política para SQS (ECS)
resource "aws_iam_policy" "ecs_sqs" {
  name        = "${var.project_name}-ecs-sqs-${var.environment}"
  description = "Permisos para ECS acceder a SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-sqs-${var.environment}"
    Environment = var.environment
  })
}

# Política para SNS (ECS)
resource "aws_iam_policy" "ecs_sns" {
  name        = "${var.project_name}-ecs-sns-${var.environment}"
  description = "Permisos para ECS publicar en SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-sns-${var.environment}"
    Environment = var.environment
  })
}

# Política para Secrets Manager (ECS)
resource "aws_iam_policy" "ecs_secrets" {
  name        = "${var.project_name}-ecs-secrets-${var.environment}"
  description = "Permisos para ECS acceder a Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_arn
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-secrets-${var.environment}"
    Environment = var.environment
  })
}

# Política para OpenSearch (ECS)
resource "aws_iam_policy" "ecs_opensearch" {
  name        = "${var.project_name}-ecs-opensearch-${var.environment}"
  description = "Permisos para ECS acceder a OpenSearch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete"
        ]
        Resource = "${var.opensearch_arn}/*"
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-opensearch-${var.environment}"
    Environment = var.environment
  })
}

# Política para CloudWatch (ECS - métricas)
resource "aws_iam_policy" "ecs_cloudwatch" {
  name        = "${var.project_name}-ecs-cloudwatch-${var.environment}"
  description = "Permisos para ECS publicar métricas en CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-cloudwatch-${var.environment}"
    Environment = var.environment
  })
}

# Política para Cloud Map (ECS - descubrimiento de servicios)
resource "aws_iam_policy" "ecs_cloudmap" {
  name        = "${var.project_name}-ecs-cloudmap-${var.environment}"
  description = "Permisos para ECS usar Cloud Map"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "servicediscovery:RegisterInstance",
          "servicediscovery:DeregisterInstance",
          "servicediscovery:DiscoverInstances",
          "servicediscovery:GetInstance",
          "servicediscovery:ListInstances"
        ]
        Resource = [
          var.cloud_map_namespace_arn,
          "${var.cloud_map_namespace_arn}/*"
        ]
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-ecs-cloudmap-${var.environment}"
    Environment = var.environment
  })
}


# ASOCIACIÓN DE POLÍTICAS A ROLES (ATTACHMENTS)


# Lambda Attachments
resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_sqs.arn
}

resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_sns.arn
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_secrets.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

# ECS Task Execution Attachments
resource "aws_iam_role_policy_attachment" "ecs_execution_ecr" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_ecr.arn
}

resource "aws_iam_role_policy_attachment" "ecs_execution_logs" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_logs.arn
}

# ECS Task (Application) Attachments
resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_s3.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_sqs" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_sqs.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_sns" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_sns.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_secrets.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_opensearch" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_opensearch.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudmap" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_cloudmap.arn
}


# POLÍTICA PARA VPC FLOW LOGS 


resource "aws_iam_policy" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name        = "${var.project_name}-vpc-flow-logs-${var.environment}"
  description = "Permisos para VPC Flow Logs escribir en CloudWatch"

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
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/*"
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-vpc-flow-logs-${var.environment}"
    Environment = var.environment
  })
}
