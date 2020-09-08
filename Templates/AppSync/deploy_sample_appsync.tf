module "test-graphQL" {
  source = ".//../../../../Terraform/AppSync" 

  # tags
  region            = "us-west-2"
  account_id        = "962004002375"
  api_name          = "sample"
  # Schema
  schema            = "${file("./templates/schema.graphql")}"

  # Data source if exists

  
  # Resolver
  resolver_field    = "singlePost"
  resolver_type     = "Query"
  request_template  = <<EOF
                      {
                        "version": "2018-05-29",
                        "method": "GET",
                        "resourcePath": "/",
                        "params":{
                          "headers": $utils.http.copyheaders($ctx.request.headers)
                        }
                      }
                      EOF
  response_template = <<EOF
                      #if($ctx.result.statusCode == 200)
                        $ctx.result.body
                      #else
                        $utils.appendError($ctx.result.body, $ctx.result.statusCode)
                      #end
                      EOF

    type            = "NONE"
}

