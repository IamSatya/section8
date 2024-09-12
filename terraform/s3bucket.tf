resource "aws_s3_bucket" "mlopsbucket" {
  bucket = "aws-mlops-satya"
}

resource "aws_s3_bucket_versioning" "mlopsver" {
  bucket = aws_s3_bucket.mlopsbucket.id
  versioning_configuration {
    status = "Enabled"
  }
}