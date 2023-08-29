terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    default_tags {
      tags = {
        Env = local.env
      }
    }
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

locals {
  env = "staging"
  db_port = "5432"
  be_port = "8000"
}

module "network" {
  source = "../modules/network"

  env = local.env
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key 
}

module "db" {
  source = "../modules/server"

  env  = local.env
  name = "db"
  region = var.region

  access_key = var.access_key
  secret_key = var.secret_key 

  vpc_id = module.network.vpc_id
  subnet_main = module.network.subnet_main
  port_range = local.db_port

  init_script_envs = {
  username = var.username
  password = var.password
  db = "lionforum"
  db_port = local.db_port
  db_user = var.db_user
  db_password = var.db_password
  }

  init_script_path = "db_init_script.tftpl"
}