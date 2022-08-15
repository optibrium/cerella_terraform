locals {
  policy = var.create_policy ? data.aws_iam_policy_document.policy[0].json : var.policy
}
resource "aws_iam_policy" "policy" {
  count = var.create_policy ? 1 : 0

  name_prefix = var.name_prefix
  description = var.description
  path        = var.path
  policy      = local.policy

  tags = var.tags
}

data "aws_iam_policy_document" "policy" {
  count = var.create_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid       = try(statement.value.sid, null)
      effect    = try(statement.value.effect, null)
      actions   = try(statement.value.actions, null)
      resources = try(statement.value.resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }
    }
  }
}