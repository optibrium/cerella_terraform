resource "random_password" "admin_password" {
  length  = 32
  special = true
  numeric = true
  upper   = true
  lower   = true
   lifecycle {
    ignore_changes = [
      length,
    ]
  }
  
}

resource "random_password" "ingest_password" {
  length  = 32
  special = true
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "cerella_admin" {
  name = "CERELLA_ADMIN"
}

resource "aws_secretsmanager_secret_version" "cerella_admin" {
  secret_id     = aws_secretsmanager_secret.cerella_admin.id
  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
  secret_string = <<EOF
   {
    "ADMIN_USERNAME": "admin",
    "ADMIN_PASSWORD": "${random_password.admin_password.result}"
   }
EOF
}

resource "aws_secretsmanager_secret" "cerella_ingest" {
  name = "CERELLA_INGEST"
}

resource "aws_secretsmanager_secret_version" "cerella_ingest" {
  secret_id     = aws_secretsmanager_secret.cerella_ingest.id
  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
  secret_string = <<EOF
   {
    "INGEST_USERNAME": "admin",
    "INGEST_PASSWORD": "${random_password.ingest_password.result}",
    "CDD_TOKEN": ""
   }
EOF
}

resource "aws_secretsmanager_secret" "cerella_licence" {
  name = "CERELLA_LICENCE"
}


resource "aws_secretsmanager_secret_version" "cerella_licence" {
  secret_id     = aws_secretsmanager_secret.cerella_licence.id
  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
  secret_string = <<EOF
   {
    "INTELLEGENS_INTERMEDIATE_LICENCE": "",
    "INTELLEGENS_LICENCE": ""
   }
EOF
}

