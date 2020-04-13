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