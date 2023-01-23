resource "random_password" "admin_password" {
  count   = var.create_secretsmanager ? 1 : 0
  length  = 32
  special = true
  numeric = true
  upper   = true
  lower   = true
}

resource "random_password" "ingest_password" {
  count   = var.create_secretsmanager ? 1 : 0
  length  = 32
  special = true
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "cerella_admin" {
  count = var.create_secretsmanager ? 1 : 0
  name  = "CERELLA_ADMIN"
}

resource "aws_secretsmanager_secret_version" "cerella_admin" {
  count         = var.create_secretsmanager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.cerella_admin[0].id
  secret_string = <<EOF
   {
    "ADMIN_USERNAME": "admin",
    "ADMIN_PASSWORD": "${random_password.admin_password[0].result}"
   }
EOF
}

resource "aws_secretsmanager_secret" "cerella_ingest" {
  count = var.create_secretsmanager ? 1 : 0
  name  = "CERELLA_INGEST"
}

resource "aws_secretsmanager_secret_version" "cerella_ingest" {
  count         = var.create_secretsmanager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.cerella_ingest[0].id
  secret_string = <<EOF
   {
    "INGEST_USERNAME": "admin",
    "INGEST_PASSWORD": "${random_password.ingest_password[0].result}",
    "CDD_TOKEN": "${var.cdd_token}"
   }
EOF
}

resource "aws_secretsmanager_secret" "cerella_licence" {
  count = var.create_secretsmanager ? 1 : 0
  name  = "CERELLA_LICENCE"
}

resource "aws_secretsmanager_secret_version" "cerella_licence" {
  count         = var.create_secretsmanager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.cerella_licence[0].id
  secret_string = <<EOF
   {
    "INTELLEGENS_INTERMEDIATE_LICENCE": '${var.intellegens_intermediate_licence}',
    "INTELLEGENS_LICENCE": '${var.intellegens_licence}'
   }
EOF
}

