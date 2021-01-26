#
# @author GDev
# @date november 2020
#

resource "aws_db_subnet_group" "aaa" {
  name       = "aaa"
  subnet_ids = [aws_subnet.right.id, aws_subnet.left.id]

  tags = {
    Name = "CerellaAAA"
  }
}

resource "aws_rds_cluster" "aaa" {
  backup_retention_period = 5
  cluster_identifier      = "cerella-aaa"
  database_name           = "AAA"
  db_subnet_group_name    = aws_db_subnet_group.aaa.name
  engine                  = "aurora-postgresql"
  engine_version          = "12.4"
  master_username         = "AAA"
  master_password         = "PLEASEDEARGODCHANGEME"
  preferred_backup_window = "01:00-03:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.aaa_db.id]
}

resource "aws_rds_cluster_instance" "aaa" {
  cluster_identifier   = aws_rds_cluster.aaa.id
  count                = var.db-instance-count
  db_subnet_group_name = aws_db_subnet_group.aaa.name
  engine               = "aurora-postgresql"
  identifier           = "aaa-${count.index}"
  instance_class       = "db.t3.medium"
}
