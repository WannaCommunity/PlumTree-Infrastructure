locals {
  origins = [{
    origin_id = "green",
    domain_name = "${data.aws_api_gateway_rest_api.green_api_gateway.id}.execute-api.eu-west-1.amazonaws.com",
  }, {
    origin_id = "blue",
    domain_name = "${data.aws_api_gateway_rest_api.blue_api_gateway.id}.execute-api.eu-west-1.amazonaws.com",
  }]
}

data "aws_api_gateway_rest_api" "green_api_gateway" {
  name = "plum-tree-green"
}

data "aws_api_gateway_rest_api" "blue_api_gateway" {
  name = "plum-tree-blue"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Plum Tree"
}

resource "aws_cloudfront_distribution" "distribution" {
  dynamic "origin" {
    for_each = local.origins

    content {
      domain_name = origin.value.domain_name
      origin_path = "/live"
      origin_id = origin.value.origin_id

      # add custom headers so we can differentiate live traffic from traffic
      # bypassing the CDN and see what origin is being used
      custom_header {
        name = "x-live"
        value = "true"
      }
      custom_header {
        name = "x-live-color"
        value = origin.value.origin_id
      }

      custom_origin_config {
        http_port = 80
        https_port = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.color

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.color

    forwarded_values {
      headers = ["Authorization"]

      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  ordered_cache_behavior {
    path_pattern     = "*.html"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.color

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_100"
  aliases = [
    "www.${var.domain}",
    var.domain,
  ]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.certificate.certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  default_root_object = "index.html"
  is_ipv6_enabled     = true
  enabled             = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
