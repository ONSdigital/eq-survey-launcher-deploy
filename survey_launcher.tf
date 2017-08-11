resource "aws_alb_target_group" "survey_launcher" {
  name     = "${var.env}-survey-launcher-ecs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_alb.eq.vpc_id}"

  health_check = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 2
  }

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener_rule" "survey_launcher" {
  listener_arn = "${data.aws_alb_listener.eq.arn}"
  priority     = "${var.alb_listener_rule_priority_offset + 100}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.survey_launcher.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.survey_launcher.name}"]
  }
}

resource "aws_route53_record" "survey_launcher" {
  zone_id = "${data.aws_route53_zone.dns_zone.id}"
  name    = "${var.env}-surveys-launch.${data.aws_route53_zone.dns_zone.name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${data.aws_alb.eq.dns_name}"]
}

data "template_file" "survey_launcher" {
  template = "${file("${path.module}/task-definitions/survey-launcher.json")}"

  vars {
    SURVEY_RUNNER_URL       = "${var.survey_runner_url}"
    JWT_ENCRYPTION_KEY_PATH = "${var.jwt_encryption_key_path}"
    JWT_SIGNING_KEY_PATH    = "${var.jwt_signing_key_path}"
    SECRETS_S3_BUCKET       = "${var.s3_secrets_bucket}"
    LOG_GROUP               = "${aws_cloudwatch_log_group.survey_launcher.name}"
    CONTAINER_TAG           = "${var.survey_launcher_tag}"
  }
}

resource "aws_ecs_task_definition" "survey_launcher" {
  family                = "${var.env}-survey-launcher"
  container_definitions = "${data.template_file.survey_launcher.rendered}"
  task_role_arn         = "${aws_iam_role.survey_launcher_task.arn}"
}

resource "aws_ecs_service" "survey_launcher" {
  depends_on = [
    "aws_alb_target_group.survey_launcher",
    "aws_alb_listener_rule.survey_launcher",
  ]

  name            = "${var.env}-survey-launcher"
  cluster         = "${data.aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.survey_launcher.family}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.survey_launcher.arn}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.survey_launcher.arn}"
    container_name   = "survey-launcher"
    container_port   = 8000
  }
}

resource "aws_iam_role" "survey_launcher" {
  name = "${var.env}_iam_for_survey_launcher"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "survey_launcher" {
  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "elasticloadbalancing:*",
    ]

    "resources" = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "survey_launcher" {
  name   = "${var.env}_iam_for_survey_launcher"
  role   = "${aws_iam_role.survey_launcher.id}"
  policy = "${data.aws_iam_policy_document.survey_launcher.json}"
}

resource "aws_iam_role" "survey_launcher_task" {
  name = "${var.env}_iam_for_survey_launcher_task"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "survey_launcher_task" {
  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "s3:GetObject",
      "s3:ListObjects",
      "s3:ListBucket",
    ]

    "resources" = [
      "arn:aws:s3:::${var.s3_secrets_bucket}",
      "arn:aws:s3:::${var.s3_secrets_bucket}/*",
    ]
  }
}

resource "aws_iam_role_policy" "survey_launcher_task" {
  name   = "${var.env}_iam_for_survey_launcher_task"
  role   = "${aws_iam_role.survey_launcher_task.id}"
  policy = "${data.aws_iam_policy_document.survey_launcher_task.json}"
}

resource "aws_cloudwatch_log_group" "survey_launcher" {
  name = "${var.env}-survey-launcher"

  tags {
    Environment = "${var.env}"
  }
}

output "survey_runner_launcher_address" {
  value = "https://${aws_route53_record.survey_launcher.fqdn}"
}
