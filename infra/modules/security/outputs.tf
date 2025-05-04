output "alb_security_group_ids" {
  description = "Security group IDs for ALB"
  value       = [aws_security_group.alb_sg.id]
}

output "ec2_security_group_ids" {
  description = "Security group IDs for EC2 instances"
  value       = [aws_security_group.ec2_sg.id]
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds_sg.id
}
output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}
