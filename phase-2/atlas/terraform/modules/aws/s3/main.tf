resource "aws_s3_bucket" "report" {
  bucket        = var.s3_bucket_name
  force_destroy = var.s3_force_destroy

  tags = merge(var.s3_tags, {
    Name = var.s3_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "report" {
  bucket = aws_s3_bucket.report.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "report" {
  bucket = aws_s3_bucket.report.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "worker_s3" {
  statement {
    sid       = "GetReportBucketLocation"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.report.arn]
  }

  statement {
    sid       = "ListReportPrefix"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.report.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["reports/*"]
    }
  }

  statement {
    sid = "WriteReports"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.report.arn}/reports/*"]
  }
}

resource "aws_iam_policy" "worker_s3" {
  name        = "${var.s3_bucket_name}-worker-write"
  description = "Allow worker nodes to write report objects to ${var.s3_bucket_name}."
  policy      = data.aws_iam_policy_document.worker_s3.json

  tags = var.s3_tags
}
