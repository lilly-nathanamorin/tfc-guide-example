provider "aws" {
  version = "2.33.0"

  region = var.aws_region
}

resource "aws_dynamodb_table" "tfc_example_table" {
  name = var.db_table_name

  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "UUID"

  attribute {
    name = "UUID"
    type = "S"
  }

  tags = {
    user_name = var.tag_user_name
  }
}

data "aws_vpc" "selected" {
 filter {
  name  = "tag:AWS_Solutions"
  values = ["LandingZoneStackSet"]
 }
}

data "aws_subnet_ids" "private" { 
  vpc_id = data.aws_vpc.selected.id

  tags = {
    "Network" = "Private"
  }
}



resource "aws_db_subnet_group" "default" {
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    "service": "datalake_db"
  }
}

resource "aws_db_instance" "public-db1" {
  instance_class      = "db.t3.micro"
  name                = "test"
  identifier = "public-db1"
  engine = "postgres"
  username = "postgres"
  password = "initpass"
  allocated_storage = 10
  engine_version = "11.5"
  max_allocated_storage = 50
  port = 5432

  db_subnet_group_name = aws_db_subnet_group.default.id

  storage_encrypted = true

  allow_major_version_upgrade = true
  deletion_protection = false
  skip_final_snapshot = true
  performance_insights_enabled = true

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }

  tags = {
    "service": "datalake_db"
  }
}
