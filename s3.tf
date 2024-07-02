resource "aws_s3_bucket" "loki_bucket" {
  bucket        = var.loki_bucket_name
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration_loki_bucket" {
  bucket = aws_s3_bucket.loki_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_loki_bucket" {
  bucket = aws_s3_bucket.loki_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket" "tempo_bucket" {
  bucket        = var.tempo_bucket_name
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration_tempo_bucket" {
  bucket = aws_s3_bucket.tempo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_tempo_bucket" {
  bucket = aws_s3_bucket.tempo_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}
