module "questionnaire_users_lambda" {
  # source = "git@git.mobi.asu.edu:mobile/asumobileapp_architecture?ref=dev"
  source = ".//../../../../Terraform/Lambda" 
  # lambda
  lambda_source        = "questionnaire_users"
  lambda_zip_path      = "covid_questionnaire_users_test.zip"
  lambda_runtime       = "nodejs12.x"
  lambda_memory        = "256"
  lambda_function_name = "covid_questionnaire_users_test"
  lambda_version       = "1.0.0"
  tags                 = {
    feature = "healthcheck_test"
  }
}

