### eq-survey-launcher-deploy

To deploy Survey Launcher add the following module to your terraform scripts

```
module "survey-launcher" {
  source = "github.com/ONSdigital/eq-survey-launcher-deploy?ref=launcher-deploy-terraform"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  dns_zone_id = "${var.dns_zone_id}"
  dns_zone_name = "${var.dns_zone_name}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  ecs_cluster_name = "${module.survey-runner-ecs.ecs_cluster_name}"
  aws_alb_dns_name = "${module.survey-runner-ecs.aws_alb_dns_name}"
  aws_alb_listener_arn = "${module.survey-runner-ecs.aws_alb_listener_arn}"
  survey_runner_url = "https://${var.env}-surveys.${var.dns_zone_name}"
  s3_secrets_bucket = "${var.survey_launcher_s3_secrets_bucket}"
  jwt_signing_key_path = "${var.survey_launcher_jwt_signing_key_path}"
  jwt_encryption_key_path = "${var.survey_launcher_jwt_encryption_key_path}"
}
```