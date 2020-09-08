module "covid_campus_schedule_data" {
  source = ".//../../../../Terraform/DynamoDB"  
  # Datasource
  namespace                    = "example"
  stage                        = "dev"
  name                         = "covid_campus_schedule"
  hash_key                     = "asurite"
  hash_key_type                = "S"
  range_key                    = "RangeKey"
  billing_mode                 = "PAY_PER_REQUEST"
  stream_enabled               = true
  stream_view_type             = "NEW_AND_OLD_IMAGES"
  #autoscale_write_target       = 50
  #autoscale_read_target        = 50
  #autoscale_min_read_capacity  = 5
  #autoscale_max_read_capacity  = 20
  #autoscale_min_write_capacity = 5
  #autoscale_max_write_capacity = 20
  tags                 = {
    feature = "healthcheck_test"
  }
  dynamodb_attributes = [
    {
      name = "asurite"
      type = "S"
    },
    {
      name = "Timestamp"
      type = "S"
    }
  ]

  local_secondary_index_map = [
    {
      name               = "TimestampSortIndex"
      range_key          = "Timestamp"
      projection_type    = "INCLUDE"
      non_key_attributes = ["HashKey", "RangeKey"]
    }
  ]
}
