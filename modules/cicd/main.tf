# DATA SOURCES
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# SECRETS MANAGER
resource "aws_secretsmanager_secret" "sonarqube_token" {
  name        = "${var.project_name}-sonarqube-token-${var.environment}"
  description = "Token de SonarQube para ${var.environment}"
  kms_key_id  = aws_kms_key.codebuild_cmk.arn # Asegura cifrado con llave CMK

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-sonarqube-token-${var.environment}"
  })
}

# SOLUCIÓN CKV2_AWS_57: Rotación automática para SonarQube token
resource "aws_secretsmanager_secret_rotation" "sonarqube_token_rotation" {
  secret_id           = aws_secretsmanager_secret.sonarqube_token.id
  rotation_lambda_arn = var.rotation_lambda_arn # Definir variable con la Lambda de rotación
  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_secretsmanager_secret" "github_token" {
  count       = var.enable_github_token ? 1 : 0
  name        = "${var.project_name}-github-token-${var.environment}"
  description = "GitHub token para CodeStar connection - ${var.environment}"
  kms_key_id  = aws_kms_key.codebuild_cmk.arn

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-github-token-${var.environment}"
  })
}

# SOLUCIÓN CKV2_AWS_57: Rotación para GitHub Token si aplica
resource "aws_secretsmanager_secret_rotation" "github_token_rotation" {
  count               = var.enable_github_token ? 1 : 0
  secret_id           = aws_secretsmanager_secret.github_token[0].id
  rotation_lambda_arn = var.rotation_lambda_arn
  rotation_rules {
    automatically_after_days = 30
  }
}

# CORRECCIÓN: Se eliminó el "data" duplicado de sonarqube_token que causaba colisión de nombres con el "resource"
data "aws_secretsmanager_secret_version" "sonarqube_token" {
  secret_id = aws_secretsmanager_secret.sonarqube_token.id
}


# S3 BUCKET PARA LOGS
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.project_name}-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment != "prod"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-logs-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# SOLUCIÓN CKV_AWS_145: Modificado a aws:kms con CMK propia
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codebuild_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "logs" {
  bucket        = aws_s3_bucket.logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "logs-logs/"
}

# SOLUCIÓN CKV_AWS_144: Configuración de replicación cross-region para cumplimiento S3
resource "aws_s3_bucket_replication_configuration" "logs_repl" {
  count  = var.environment == "prod" ? 1 : 0
  role   = var.s3_replication_role_arn
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "ReplicationRule"
    status = "Enabled"

    destination {
      bucket        = var.replica_bucket_arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_policy" "logs_https" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "ForceHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
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


# S3 BUCKET PARA ARTEFACTOS
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}" # Añadido Account ID para evitar colisiones globales
  force_destroy = var.environment != "prod"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-artifacts-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = var.environment == "prod" ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codebuild_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "artifacts" {
  bucket        = aws_s3_bucket.artifacts.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "artifacts-logs/"
}

resource "aws_s3_bucket_replication_configuration" "artifacts_repl" {
  count  = var.environment == "prod" ? 1 : 0
  role   = var.s3_replication_role_arn
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "ArtifactsReplication"
    status = "Enabled"
    destination {
      bucket        = var.replica_bucket_arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_policy" "artifacts_https" {
  bucket = aws_s3_bucket.artifacts.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "ForceHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
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


# S3 BUCKET PARA CLOUDTRAIL LOGS
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment != "prod"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-cloudtrail-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# SOLUCIÓN CKV_AWS_145: Modificado a aws:kms con la clave CMK
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codebuild_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "cloudtrail" {
  bucket        = aws_s3_bucket.cloudtrail_logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "cloudtrail-logs/"
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${var.project_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}"
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${var.project_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}/cloudtrail/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "ForceHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.project_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::${var.project_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}/*"
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


# CLOUDTRAIL
# SOLUCIÓN CKV2_AWS_10: Integración nativa con CloudWatch Log Group y rol IAM dedicado
resource "aws_cloudtrail" "this" {
  count                         = var.enable_cloudtrail ? 1 : 0
  name                          = "${var.project_name}-trail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.codebuild_cmk.arn

  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_events[0].arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cloudwatch_role[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.project_name}-trail-${var.environment}"
  })
}

resource "aws_cloudwatch_log_group" "cloudtrail_events" {
  count             = var.enable_cloudtrail ? 1 : 0
  name              = "/aws/cloudtrail/${var.project_name}-events-${var.environment}"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch_role" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = "${var.project_name}-cloudtrail-to-cw-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = "${var.project_name}-cloudtrail-cw-policy-${var.environment}"
  role  = aws_iam_role.cloudtrail_to_cloudwatch_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail_events[0].arn}:*"
    }]
  })
}


# IAM ROLES & POLICIES
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project_name}-pipeline-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "codepipeline.amazonaws.com" }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "codebuild.amazonaws.com" }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "codedeploy.amazonaws.com" }
      }
    ]
  })

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "${var.project_name}-secrets-access-${var.environment}"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = [
          aws_secretsmanager_secret.sonarqube_token.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_additional" {
  name = "${var.project_name}-codebuild-additional-${var.environment}"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAccess"
        Effect   = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-*"
        ]
      },
      {
        Sid      = "ECSAccess"
        Effect   = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = [
          "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecs_cluster_name}",
          "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/*"
        ]
      },
      {
        Sid      = "IAMPassRole"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
        Condition = {
          "StringEquals" = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}*"
        ]
      },
      {
        Sid      = "S3Access"
        Effect   = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Sid      = "SSMAccess"
        Effect   = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}


# KMS KEY (SOLUCIÓN CKV2_AWS_64: Gestión granular de políticas KMS)
resource "aws_kms_key" "codebuild_cmk" {
  description             = "Clave KMS gestionada por el cliente para encriptar el proyecto CodeBuild de ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow CodeBuild Service Role to use the key"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.pipeline_role.arn }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid       = "Allow S3 to use the key"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          "StringEquals" = {
            "kms:ViaService" = "s3.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.project_name}-codebuild-cmk-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_kms_alias" "codebuild_cmk_alias" {
  name          = "alias/${var.project_name}-codebuild-cmk-${var.environment}"
  target_key_id = aws_kms_key.codebuild_cmk.key_id
}


# CODEBUILD CONFIGURATIONS
resource "aws_codebuild_project" "sonarqube_scan" {
  name           = "${var.project_name}-sonarqube-${var.environment}"
  description    = "Análisis de calidad de código con SonarQube - ${var.environment}"
  service_role   = aws_iam_role.pipeline_role.arn
  encryption_key = aws_kms_key.codebuild_cmk.arn

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = var.codebuild_compute_type
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "SONAR_HOST_URL"
      value = var.sonarqube_host_url
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "SONAR_TOKEN"
      value = aws_secretsmanager_secret.sonarqube_token.name
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "SONAR_PROJECT_KEY"
      value = var.sonarqube_project_key
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "SONAR_ORGANIZATION"
      value = var.sonarqube_organization
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild_sonarqube.name
      stream_name = "sonarqube"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "sonarqube-buildspec.yml"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Component   = "SonarQube"
  })
}

resource "aws_codebuild_project" "checkov_scan" {
  count          = var.enable_checkov ? 1 : 0
  name           = "${var.project_name}-checkov-${var.environment}"
  description    = "Escaneo de seguridad con Checkov para Terraform - ${var.environment}"
  service_role   = aws_iam_role.pipeline_role.arn
  encryption_key = aws_kms_key.codebuild_cmk.arn

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = var.codebuild_compute_type
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "CHECKOV_SEVERITY"
      value = var.checkov_severity
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "CHECKOV_SKIP_RESULTS"
      value = "SKIPPED_CHECKS"
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild_checkov[0].name
      stream_name = "checkov"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "checkov-buildspec.yml"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Component   = "Checkov"
  })
}

resource "aws_codebuild_project" "app_build" {
  name           = "${var.project_name}-build-${var.environment}"
  description    = "Construcción de la imagen Docker - ${var.environment}"
  service_role   = aws_iam_role.pipeline_role.arn
  encryption_key = aws_kms_key.codebuild_cmk.arn

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = var.codebuild_compute_type
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.codebuild_privileged_mode

    environment_variable {
      name  = "LOGGING_CONFIG"
      value = "true"
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "ARTIFACTS_BUCKET"
      value = aws_s3_bucket.artifacts.bucket
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild_build.name
      stream_name = "build"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Component   = "Build"
  })
}


# CODEDEPLOY
resource "aws_codedeploy_app" "ecs" {
  name = "AppECS-${var.ecs_cluster_name}"
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name               = aws_codedeploy_app.ecs.name
  deployment_group_name  = "DgpECS-${var.ecs_service_name}"
  service_role_arn       = aws_iam_role.pipeline_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = var.codedeploy_wait_time_minutes
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.codedeploy_termination_wait_time
    }
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }
      test_traffic_route {
        listener_arns = [var.alb_test_listener_arn != "" ? var.alb_test_listener_arn : var.alb_listener_arn]
      }
      target_group { name = "tg-user-blue-${var.environment}" }
      target_group { name = "tg-user-green-${var.environment}" }
    }
  }

  auto_rollback_configuration {
    enabled = var.enable_auto_rollback
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}


# CODEPIPELINE
resource "aws_codepipeline" "this" {
  name     = "${var.project_name}-pipeline-${var.environment}"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.codebuild_cmk.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.github_repository_id
        BranchName       = var.github_branch_name
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "QualityScan"
    action {
      name             = "SonarQubeScan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["sonarqube_output"]
      configuration    = { ProjectName = aws_codebuild_project.sonarqube_scan.name }
    }
  }

  # CORRECCIÓN: Se ajustó dinámicamente la entrada/salida para el pipeline si Checkov está deshabilitado
  stage {
    name = "SecurityScan"
    action {
      name             = "SecurityOrPass"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["sonarqube_output"]
      output_artifacts = ["security_scan_output"]
      configuration = {
        ProjectName = var.enable_checkov ? aws_codebuild_project.checkov_scan[0].name : aws_codebuild_project.app_build.name
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["security_scan_output"]
      output_artifacts = ["build_output"]
      configuration    = { ProjectName = aws_codebuild_project.app_build.name }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ApplicationName                = aws_codedeploy_app.ecs.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.ecs.deployment_group_name
        TaskDefinitionTemplateArtifact = "build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "build_output"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}


# AWS BUDGETS
resource "aws_budgets_budget" "monthly" {
  count             = var.enable_budgets ? 1 : 0
  name              = "${var.project_name}-budget-${var.environment}"
  budget_type       = "COST"
  limit_amount      = var.budget_limit
  limit_unit        = "USD"
  time_period_start = "2026-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}


# CLOUDWATCH LOG GROUPS
resource "aws_cloudwatch_log_group" "codebuild_build" {
  name              = "/aws/codebuild/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Environment = var.environment, Project = var.project_name })
}

resource "aws_cloudwatch_log_group" "codebuild_sonarqube" {
  name              = "/aws/codebuild/${var.project_name}-sonarqube-${var.environment}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Environment = var.environment, Project = var.project_name })
}

resource "aws_cloudwatch_log_group" "codebuild_checkov" {
  count             = var.enable_checkov ? 1 : 0
  name              = "/aws/codebuild/${var.project_name}-checkov-${var.environment}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Environment = var.environment, Project = var.project_name })
}

# CKV2_AWS_64 — La clave KMS no tiene una política definida. Sin política explícita, el acceso a la clave queda mal definido y puede abrirse más de lo esperado.
# CKV2_AWS_57 — Los secrets en Secrets Manager no rotan automáticamente. Si una credencial se filtra, permanece válida indefinidamente hasta que alguien la cambie a mano.
# CKV_AWS_145 — Los buckets S3 no usan cifrado KMS, solo el cifrado por defecto de AWS. Sin KMS propio, no puedes revocar el acceso a los datos deshabilitando la clave.
#CKV_AWS_144 — Los buckets S3 no tienen replicación en otra región. Si la región principal falla o los datos se corrompen, no hay copia de respaldo.
# CKV2_AWS_10 — CloudTrail no está enviando los logs a CloudWatch. Sin esto, no hay alertas en tiempo real sobre actividad sospechosa en la cuenta de AWS.
