output "iam_arn" {
  description = "The ARN of the IAM instance roles of the workers in the cluster."

  value = aws_iam_role.workers.arn
}

output "iam_id" {
  description = "The id of the IAM instance roles of the workers in the cluster."

  value = aws_iam_role.workers.id
}

output "name" {
  description = "The Auto Scaling Group name."

  value = aws_autoscaling_group.workers.name
}

output "id" {
  description = "The Auto Scaling Group id."

  value = aws_autoscaling_group.workers.id
}

output "arn" {
  description = "The ARN for this Auto Scaling Group."

  value = aws_autoscaling_group.workers.arn
}
