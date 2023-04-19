# Pull DB Pass from .envrc file 
variable "DB_PASS" {
    type        = string
    description = "This env variables set by direnv in .envrc ." 
}

# Create our Database, pg 35
resource "aws_db_instance" "default" {
  allocated_storage    = 5
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  engine               = "postgres"
  engine_version       = "9.6.22"
  instance_class       = "db.t3.micro"
  identifier           = "invoicer-db"
  multi_az             = true
  name                 = "invoicer"
  username             = "invoicer"
  password             = var.DB_PASS
  skip_final_snapshot  = true
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  auto_minor_version_upgrade = true
  monitoring_interval = true
}
