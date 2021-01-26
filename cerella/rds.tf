#
# @author GDev
# @date november 2020
#

resource "aws_db_subnet_group" "aaa" {
  name       = "aaa"
  subnet_ids = ["${aws_subnet.right.id}", "${aws_subnet.left.id}"]

  tags = {
    Name = "CerellaAAA"
  }
}

resource "aws_rds_cluster" "aaa" {
  cluster_identifier      = "aaa"
  engine                  = "aurora-postgresql"
  engine_version          = "12.4"
  database_name           = "AAA"
  master_username         = "AAA"
  master_password         = "PLEASEDEARGODCHANGEME"
  backup_retention_period = 5
  preferred_backup_window = "01:00-03:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = ["${aws_security_group.aaa_db.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.aaa.name}"
}

resource "aws_rds_cluster_instance" "aaa" {
  count                   = 2
  identifier              = "aaa-${count.index}"
  engine                  = "aurora-postgresql"
  cluster_identifier      = "${aws_rds_cluster.aaa.id}"
  instance_class          = "db.t2.small"
  db_subnet_group_name    = "${aws_db_subnet_group.aaa.name}"
}
