resource "aws_wafv2_web_acl" "main" {
  name        = "${var.environment}-waf"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "BlockSQLInjection"
    priority = 1

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string         = "<script>"
        positional_constraint = "CONTAINS"

        field_to_match {
          body {}
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      sampled_requests_enabled    = true
      cloudwatch_metrics_enabled  = true
      metric_name                 = "BlockSQLInjectionMetric"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wafAclMetric"
    sampled_requests_enabled   = true
  }
}