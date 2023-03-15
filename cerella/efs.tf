data "aws_subnet" "subnets" {
  for_each = toset(local.private_subnet_ids)
  id       = each.value
}

module "efs" {
  count  = var.efs_enabled ? 1 : 0
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = var.cluster-name
  creation_token = "${var.cluster-name}-token"
  encrypted      = true
  kms_key_arn    = aws_kms_key.efs[0].arn

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # File system policy
  attach_policy                      = false
  bypass_policy_lockout_safety_check = false

  # Mount targets / security group
  mount_targets              = {for k, v in data.aws_subnet.subnets : v.availability_zone => { subnet_id = v.id }}
  security_group_description = "EFS security group"
  security_group_name        = "efs-${var.cluster-name}-sg"
  security_group_vpc_id      = var.vpc_id
  security_group_rules       = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = values(data.aws_subnet.subnets).*.cidr_block
    }
  }

  # Backup policy
  enable_backup_policy = true

  tags = {
    STATEFUL       = "true"
    BACKUP_ENABLED = "true"
  }
}

resource "aws_kms_key" "efs" {
  count                   = var.efs_enabled ? 1 : 0
  description             = "EFS Secret Encryption Key for efs-${var.cluster-name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
