resource "aws_rds_cluster" "postgres" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["ap-southeast-1a", "ap-southeast-1b"]
  database_name           = "mydb"
  master_username         = "sa"
  master_password         = "barbarbarbar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "postgres" {
  identifier         = "aurora-cluster-demo"
  cluster_identifier = aws_rds_cluster.postgres.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.postgres.engine
  engine_version     = aws_rds_cluster.postgres.engine_version
}

resource "aws_db_subnet_group" "postgres" {
  name       = "postgres"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "postgres"
  }
}
