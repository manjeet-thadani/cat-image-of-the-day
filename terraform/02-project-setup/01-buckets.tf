resource "aws_s3_bucket" "demo_website_bucket" {
    bucket = var.website_bucket_name
    acl = "public-read"
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["PUT","POST"]
      allowed_origins = ["*"]
      expose_headers = ["ETag"]
      max_age_seconds = 3000
    }

    policy = "${data.aws_iam_policy_document.demo_website_bucket_policy_document.json}"

    website {
      index_document = "index.html"
    }
}

data "aws_iam_policy_document" "demo_website_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.website_bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "demo_assets_bucket" {
    bucket = var.assets_bucket_name
    acl = "public-read"
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["PUT","POST"]
      allowed_origins = ["*"]
      expose_headers = ["ETag"]
      max_age_seconds = 3000
    }

    policy = "${data.aws_iam_policy_document.demo_assets_bucket_policy_document.json}"
}

data "aws_iam_policy_document" "demo_assets_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.assets_bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
