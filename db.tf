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

  vpc_security_group_ids = ["sg-0be08360422e0322e"] // Allow vault Access

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


resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = aws_db_instance.public-db1.name
  allowed_roles = ["*"]

  postgresql {
    connection_url = "postgres://${aws_db_instance.public-db1.username}:initpass@${aws_db_instance.public-db1.endpoint}/${aws_db_instance.public-db1.name}"
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = vault_mount.db.path
  name                = "my-role"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}