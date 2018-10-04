resource "aws_s3_bucket" "config" {
  acl     = "log-delivery-write"
  bucket  = "${local.config_name}"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id = "log"
    enabled = true

    transition {
      days = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555
    }
  }

  logging {
    target_bucket = "${var.log_bucket}"
    target_prefix = "s3/${local.config_name}/"
  }
  tags = "${var.tags}"
}

data "aws_iam_policy_document" "config" {

  statement {
    actions = [
      "s3:*"
    ]
    condition {
      test = "Bool"
      values = [
        "false"
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      "${aws_s3_bucket.config.arn}",
      "${aws_s3_bucket.config.arn}/*"
    ]
    sid = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "config" {
  bucket = "${aws_s3_bucket.config.id}"
  policy = "${data.aws_iam_policy_document.config.json}"
}
