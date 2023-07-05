resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "garnet-static-website-bucket"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "static_website_bucket" {
  bucket = aws_s3_bucket.static_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website_bucket" {
  bucket = aws_s3_bucket.static_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "static_website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_website_bucket,
    aws_s3_bucket_public_access_block.static_website_bucket,
  ]

  bucket = aws_s3_bucket.static_website_bucket.id
  acl    = "public-read"
}

# Upload index.html to S3 bucket
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key    = "index.html"
  source = "files/index.html"
  etag   = filemd5("files/index.html")
  content_type = "text/html"
}

# Upload error.html to S3 bucket
resource "aws_s3_bucket_object" "error_html" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key    = "error.html"
  source = "files/error.html"
  etag   = filemd5("files/error.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_policy" "static_website_bucket_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [
    aws_s3_bucket_acl.static_website_bucket
  ]
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.static_website_bucket.arn, "${aws_s3_bucket.static_website_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_object" "image" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key    = "down.jpg"
  source = "files/down.jpg"
  content_type = "image/jpeg"
}
