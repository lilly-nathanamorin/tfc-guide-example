provider "aws" {
  version = "2.33.0"

  region = var.aws_region
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