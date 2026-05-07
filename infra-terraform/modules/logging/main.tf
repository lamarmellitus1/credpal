resource "aws_cloudwatch_log_group" "application" {
  name              = "/ecs/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.environment}-payment-gateway-logs"
  }
}
