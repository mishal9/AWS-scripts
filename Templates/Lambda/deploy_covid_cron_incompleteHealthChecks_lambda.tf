module "covid_cron_incomplete_health_checks_lambda" {
  # source = "git@git.mobi.asu.edu:mobile/asumobileapp_architecture?ref=dev"
  source = ".//../../../../Terraform/Lambda" 
  # lambda
  lambda_source        = "covid_cron_incompleteHealthChecks"
  lambda_zip_path      = "covid_cron_incompleteHealthChecks_test.zip"
  lambda_runtime       = "nodejs12.x"
  lambda_memory        = "256"
  lambda_function_name = "covid_cron_incompleteHealthChecks_test"
  lambda_version       = "1.0.0"
  has_variables        = "true"
  variables = {
    questionnaire_dynamo_table = "covid_questionnaire",
    feature                    = "covid",
    sqs_queue                  = "ASUHealthCheckQueuetoODS_Nonprod"
  }
  tags                 = {
    feature = "healthcheck_test"
  }

  # vpc
  #vpc_id  = "vpc-0bc7af6827370784b"
  #subnets = [""]

  # Cloudwatch event
  schedule_expression      = "rate(1 minute)"
}
