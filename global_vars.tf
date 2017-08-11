variable "env" {
  description = "The environment you wish to use"
}

variable "aws_secret_key" {
  description = "Amazon Web Service Secret Key"
}

variable "aws_access_key" {
  description = "Amazon Web Service Access Key"
}

variable "ecs_cluster_name" {
  description = "The name of the survey runner ECS cluster"
}

variable "aws_alb_listener_arn" {
  description = "The ARN of the survey runner ALB"
}

# DNS
variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "eq.ons.digital."
}

# Survey Launcher
variable "survey_launcher_tag" {
  description = "The tag for the Survey Launcher image to run"
  default     = "latest"
}

variable "s3_secrets_bucket" {
  description = "The S3 bucket that contains the secrets"
}

variable "jwt_encryption_key_path" {
  description = "Path to the JWT Encryption Key (PEM format)"
}

variable "jwt_signing_key_path" {
  description = "Path to the JWT Signing Key (PEM format)"
}

variable "survey_runner_url" {
  description = "The base URL of Survey Runner to redirect to"
}

variable "alb_listener_rule_priority_offset" {
  description = "An amount to offset the alb_listener_rule priority. This allows for multiple launchers to be deployed"
  default = 0
}