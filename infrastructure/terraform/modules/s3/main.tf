variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
