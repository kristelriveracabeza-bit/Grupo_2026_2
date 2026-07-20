
# OUTPUTS DE ROLES IAM


output "lambda_role_arn" {
  description = "ARN del rol IAM de Lambda"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "Nombre del rol IAM de Lambda"
  value       = aws_iam_role.lambda.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN del rol IAM de ECS Task Execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Nombre del rol IAM de ECS Task Execution"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "ARN del rol IAM de ECS Task (aplicación)"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Nombre del rol IAM de ECS Task (aplicación)"
  value       = aws_iam_role.ecs_task.name
}

output "cognito_role_arn" {
  description = "ARN del rol IAM de Cognito"
  value       = aws_iam_role.cognito.arn
}

output "cognito_role_name" {
  description = "Nombre del rol IAM de Cognito"
  value       = aws_iam_role.cognito.name
}


# OUTPUTS DE POLÍTICAS IAM


output "lambda_policy_arns" {
  description = "ARNs de las políticas de Lambda"
  value = {
    sqs      = aws_iam_policy.lambda_sqs.arn
    sns      = aws_iam_policy.lambda_sns.arn
    secrets  = aws_iam_policy.lambda_secrets.arn
    dynamodb = aws_iam_policy.lambda_dynamodb.arn
    logs     = aws_iam_policy.lambda_logs.arn
  }
}

output "ecs_execution_policy_arns" {
  description = "ARNs de las políticas de ECS Task Execution"
  value = {
    ecr  = aws_iam_policy.ecs_ecr.arn
    logs = aws_iam_policy.ecs_logs.arn
  }
}

output "ecs_task_policy_arns" {
  description = "ARNs de las políticas de ECS Task (aplicación)"
  value = {
    dynamodb   = aws_iam_policy.ecs_dynamodb.arn
    s3         = aws_iam_policy.ecs_s3.arn
    sqs        = aws_iam_policy.ecs_sqs.arn
    sns        = aws_iam_policy.ecs_sns.arn
    secrets    = aws_iam_policy.ecs_secrets.arn
    opensearch = aws_iam_policy.ecs_opensearch.arn
    cloudwatch = aws_iam_policy.ecs_cloudwatch.arn
    cloudmap   = aws_iam_policy.ecs_cloudmap.arn
  }
}


# OUTPUTS DE POLÍTICAS ADICIONALES


output "vpc_flow_logs_policy_arn" {
  description = "ARN de la política para VPC Flow Logs"
  value       = var.enable_vpc_flow_logs ? aws_iam_policy.vpc_flow_logs[0].arn : null
}
