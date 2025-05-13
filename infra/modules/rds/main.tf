resource "aws_db_subnet_group" "default" {
  name       = "rds-public-subnet-group"
  subnet_ids = var.public_subnets

  tags = {
    Name = "RDS Public Subnet Group"
  }
}

module "rds_mysql" {
  source              = "terraform-aws-modules/rds/aws"
  identifier          = "mysql-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_encrypted   = true
  multi_az            = false  # single AZ for simplicity
  username            = var.db_username
  password            = var.db_password
  db_name             = var.db_name
  vpc_security_group_ids = [var.ec2_security_group_id]

  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.default.name

  skip_final_snapshot = true  # optional: avoid snapshot issues on destroy
  major_engine_version    = "8.0"
  family                  = "mysql8.0"
}