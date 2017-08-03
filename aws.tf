provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "ecs-cluster" {
  cluster_name = "${var.ecs_cluster_name}"
}
