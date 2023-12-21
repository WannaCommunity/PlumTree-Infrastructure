resource "aws_api_gateway_rest_api" "api" {
  description              = "API Gateway for the Plum Tree ${terraform.workspace}"
  name                     = local.name_prefix
  minimum_compression_size = 0
  binary_media_types       = ["*/*"]

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Uploads (Processed)
# Endpoint to get the original non-downsized uploaded image. We use this when
# the image has previously uploaded and saved but the user wants to modify it
# such as crop the image before saving a new version.

resource "aws_api_gateway_resource" "uploads" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "uploads"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "uploads_item" {
  parent_id   = aws_api_gateway_resource.uploads.id
  path_part   = "{item+}"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "uploads_item" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.uploads_item.id
  rest_api_id   = aws_api_gateway_rest_api.api.id

  request_parameters = {
    "method.request.header.If-Modified-Since" = false,
    "method.request.header.If-None-Match"     = false,
    "method.request.path.item"                = true
  }
}

resource "aws_api_gateway_integration" "uploads_item" {
  http_method             = aws_api_gateway_method.uploads_item.http_method
  resource_id             = aws_api_gateway_resource.uploads_item.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:eu-west-1:s3:path/${data.aws_s3_bucket.uploads_bucket.id}/{item}"
  credentials             = aws_iam_role.uploads_s3_api_gateyway_role.arn

  request_parameters = {
    "integration.request.header.If-Modified-Since" = "method.request.header.If-Modified-Since"
    "integration.request.header.If-None-Match"     = "method.request.header.If-None-Match"
    "integration.request.path.item"                = "method.request.path.item"
  }
}

resource "aws_api_gateway_method_response" "uploads_item" {
  http_method = aws_api_gateway_method.uploads_item.http_method
  resource_id = aws_api_gateway_resource.uploads_item.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Content-Length"            = true,
    "method.response.header.Content-Type"              = true,
    "method.response.header.ETag"                      = true,
    "method.response.header.Last-Modified"             = true,
  }
}

resource "aws_api_gateway_integration_response" "uploads_item" {
  http_method      = aws_api_gateway_method.uploads_item.http_method
  resource_id      = aws_api_gateway_resource.uploads_item.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  status_code      = aws_api_gateway_method_response.uploads_item.status_code
  content_handling = "CONVERT_TO_BINARY"

  response_parameters = {
    "method.response.header.Cache-Control"             = "'max-age=31536000'"
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.ETag"                      = "integration.response.header.ETag",
    "method.response.header.Last-Modified"             = "integration.response.header.Last-Modified",
  }

  depends_on = [aws_api_gateway_integration.uploads_item]
}

resource "aws_api_gateway_method_response" "cached_uploads_item" {
  http_method = aws_api_gateway_method.uploads_item.http_method
  resource_id = aws_api_gateway_resource.uploads_item.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "304"

  response_parameters = {
    "method.response.header.Cache-Control"  = true,
    "method.response.header.ETag"           = true,
    "method.response.header.Last-Modified"  = true,
  }
}

resource "aws_api_gateway_integration_response" "cached_uploads_item" {
  http_method       = aws_api_gateway_method.uploads_item.http_method
  resource_id       = aws_api_gateway_resource.uploads_item.id
  rest_api_id       = aws_api_gateway_rest_api.api.id
  status_code       = aws_api_gateway_method_response.cached_uploads_item.status_code
  content_handling  = "CONVERT_TO_BINARY"
  selection_pattern = "304"

  response_parameters = {
    "method.response.header.Cache-Control"  = "'max-age=31536000'",
    "method.response.header.ETag"           = "integration.response.header.ETag",
    "method.response.header.Last-Modified"  = "integration.response.header.Last-Modified",
  }

  depends_on = [aws_api_gateway_integration.uploads_item]
}

# Uploads (Input)
# Endpoint to get the original non-downsized uploaded image before being moved
# to the processed bucket. We use this when the image was just uploaded and the
# user may wish to crop the image before saving. Note these images only stay
# here for 1 day.

resource "aws_api_gateway_resource" "uploads_original" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "uploads-orig"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "uploads_original_item" {
  parent_id   = aws_api_gateway_resource.uploads_original.id
  path_part   = "{item+}"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "uploads_original_item" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.uploads_original_item.id
  rest_api_id   = aws_api_gateway_rest_api.api.id

  request_parameters = {
    "method.request.header.If-Modified-Since" = false,
    "method.request.header.If-None-Match"     = false,
    "method.request.path.item"                = true
  }
}

resource "aws_api_gateway_integration" "uploads_original_item" {
  http_method             = aws_api_gateway_method.uploads_original_item.http_method
  resource_id             = aws_api_gateway_resource.uploads_original_item.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:eu-west-1:s3:path/${data.aws_s3_bucket.uploads_input_bucket.id}/{item}"
  credentials             = aws_iam_role.uploads_input_s3_api_gateyway_role.arn

  request_parameters = {
    "integration.request.header.If-Modified-Since" = "method.request.header.If-Modified-Since"
    "integration.request.header.If-None-Match"     = "method.request.header.If-None-Match"
    "integration.request.path.item"                = "method.request.path.item"
  }
}

resource "aws_api_gateway_method_response" "uploads_original_item" {
  http_method = aws_api_gateway_method.uploads_original_item.http_method
  resource_id = aws_api_gateway_resource.uploads_original_item.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Cache-Control"             = true,
    "method.response.header.Content-Length"            = true,
    "method.response.header.Content-Type"              = true,
    "method.response.header.ETag"                      = true,
    "method.response.header.Last-Modified"             = true,
  }
}

resource "aws_api_gateway_integration_response" "uploads_original_item" {
  http_method      = aws_api_gateway_method.uploads_original_item.http_method
  resource_id      = aws_api_gateway_resource.uploads_original_item.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  status_code      = aws_api_gateway_method_response.uploads_original_item.status_code
  content_handling = "CONVERT_TO_BINARY"

  response_parameters = {
    "method.response.header.Cache-Control"             = "'max-age=31536000'"
    "method.response.header.Content-Length"            = "integration.response.header.Content-Length",
    "method.response.header.Content-Type"              = "integration.response.header.Content-Type",
    "method.response.header.ETag"                      = "integration.response.header.ETag",
    "method.response.header.Last-Modified"             = "integration.response.header.Last-Modified",
  }

  depends_on = [aws_api_gateway_integration.uploads_original_item]
}

resource "aws_api_gateway_method_response" "cached_uploads_original_item" {
  http_method = aws_api_gateway_method.uploads_original_item.http_method
  resource_id = aws_api_gateway_resource.uploads_original_item.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "304"

  response_parameters = {
    "method.response.header.Cache-Control"  = true,
    "method.response.header.ETag"           = true,
    "method.response.header.Last-Modified"  = true,
  }
}

resource "aws_api_gateway_integration_response" "cached_uploads_original_item" {
  http_method       = aws_api_gateway_method.uploads_original_item.http_method
  resource_id       = aws_api_gateway_resource.uploads_original_item.id
  rest_api_id       = aws_api_gateway_rest_api.api.id
  status_code       = aws_api_gateway_method_response.cached_uploads_original_item.status_code
  content_handling  = "CONVERT_TO_BINARY"
  selection_pattern = "304"

  response_parameters = {
    "method.response.header.Cache-Control"  = "'max-age=31536000'",
    "method.response.header.ETag"           = "integration.response.header.ETag",
    "method.response.header.Last-Modified"  = "integration.response.header.Last-Modified",
  }

  depends_on = [aws_api_gateway_integration.uploads_original_item]
}

# Static Assets
# Any requests to the static assets. These are proxied to the S3 static assets
# bucket. These are files such as JavaScript, CSS, Fonts or Images (not user
# uploaded ones)

resource "aws_api_gateway_resource" "assets" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "assets"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "assets_item" {
  parent_id   = aws_api_gateway_resource.assets.id
  path_part   = "{item+}"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "assets_item" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.assets_item.id
  rest_api_id   = aws_api_gateway_rest_api.api.id

  request_parameters = {
    "method.request.path.item" = true
  }
}

resource "aws_api_gateway_integration" "assets_item" {
  http_method             = aws_api_gateway_method.assets_item.http_method
  resource_id             = aws_api_gateway_resource.assets_item.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:eu-west-1:s3:path/${aws_s3_bucket.static_assets.id}/{item}"
  credentials             = aws_iam_role.assets_s3_api_gateyway_role.arn

  request_parameters = {
    "integration.request.path.item" = "method.request.path.item"
  }
}

resource "aws_api_gateway_method_response" "assets_item" {
  http_method = aws_api_gateway_method.assets_item.http_method
  resource_id = aws_api_gateway_resource.assets_item.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Length" = true,
    "method.response.header.Content-Type" = true,
    "method.response.header.Strict-Transport-Security" = true,
    "method.response.header.X-Content-Type-Options" = true,
  }
}

resource "aws_api_gateway_integration_response" "assets_item" {
  http_method      = aws_api_gateway_method.assets_item.http_method
  resource_id      = aws_api_gateway_resource.assets_item.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  status_code      = aws_api_gateway_method_response.assets_item.status_code
  content_handling = "CONVERT_TO_BINARY"

  response_parameters = {
    "method.response.header.Content-Length" = "integration.response.header.Content-Length",
    "method.response.header.Content-Type" = "integration.response.header.Content-Type",
    "method.response.header.Strict-Transport-Security" = "'max-age=31536000; includeSubDomains; preload'",
    "method.response.header.X-Content-Type-Options" = "'nosniff'",
  }

  depends_on = [aws_api_gateway_integration.assets_item]
}

# Root Resource
# When a user goes to the root resource (e.g. the domain with no path
# "https://theplumtreeapp.com") we serve the index.html file from static assets

resource "aws_api_gateway_method" "root_item" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.api.id

  request_parameters = {
    "method.request.path.item" = true
  }
}

resource "aws_api_gateway_integration" "root_item" {
  http_method             = aws_api_gateway_method.root_item.http_method
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:eu-west-1:s3:path/${aws_s3_bucket.static_assets.id}/index.html"
  credentials             = aws_iam_role.assets_s3_api_gateyway_role.arn
}

resource "aws_api_gateway_method_response" "root_item" {
  http_method = aws_api_gateway_method.root_item.http_method
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Length" = true,
    "method.response.header.Content-Type" = true,
    "method.response.header.Strict-Transport-Security" = true,
    "method.response.header.X-Content-Type-Options" = true,
  }
}

resource "aws_api_gateway_integration_response" "root_item" {
  http_method      = aws_api_gateway_method.root_item.http_method
  resource_id      = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  status_code      = aws_api_gateway_method_response.root_item.status_code
  content_handling = "CONVERT_TO_BINARY"

  response_parameters = {
    "method.response.header.Content-Length" = "integration.response.header.Content-Length",
    "method.response.header.Content-Type" = "integration.response.header.Content-Type",
    "method.response.header.Strict-Transport-Security" = "'max-age=31536000; includeSubDomains; preload'",
    "method.response.header.X-Content-Type-Options" = "'nosniff'",
  }

  depends_on = [aws_api_gateway_integration.root_item]
}

# Any Resource
# Any endpoint/path not already covered we default to the index.html file from
# static assets.

resource "aws_api_gateway_resource" "index" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{any+}"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "index" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.index.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_integration" "index" {
  http_method             = aws_api_gateway_method.index.http_method
  resource_id             = aws_api_gateway_resource.index.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:eu-west-1:s3:path/${aws_s3_bucket.static_assets.id}/index.html"
  credentials             = aws_iam_role.assets_s3_api_gateyway_role.arn
}

resource "aws_api_gateway_method_response" "index" {
  http_method = aws_api_gateway_method.index.http_method
  resource_id = aws_api_gateway_resource.index.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Length" = true,
    "method.response.header.Content-Type" = true,
    "method.response.header.Strict-Transport-Security" = true,
    "method.response.header.X-Content-Type-Options" = true,
  }
}

resource "aws_api_gateway_integration_response" "index" {
  http_method      = aws_api_gateway_method.index.http_method
  resource_id      = aws_api_gateway_resource.index.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  status_code      = aws_api_gateway_method_response.index.status_code
  content_handling = "CONVERT_TO_BINARY"

  response_parameters = {
    "method.response.header.Content-Length" = "integration.response.header.Content-Length",
    "method.response.header.Content-Type" = "integration.response.header.Content-Type",
    "method.response.header.Strict-Transport-Security" = "'max-age=31536000; includeSubDomains; preload'",
    "method.response.header.X-Content-Type-Options" = "'nosniff'",
  }

  depends_on = [aws_api_gateway_integration.index]
}

# Domain
# Setup the color subdomain and HTTPS certificate

resource "aws_api_gateway_domain_name" "domain" {
  domain_name              = aws_acm_certificate.certificate.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.certificate.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "live" {
  depends_on = [
    aws_api_gateway_integration_response.root_item
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "live"
  description = "Temporary deployment to connect the base path mapping for custom domains"
}

resource "aws_api_gateway_base_path_mapping" "live" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.live.stage_name
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}
