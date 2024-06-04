terraform {
  required_version = ">=1.6.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "hospitalucas"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_website_configuration" "bucket_website" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example_bucket,
    aws_s3_bucket_public_access_block.public_access_block,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_ownership_controls" "example_bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowPublicRead",
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.bucket.arn}/*"
        ],
      },
    ],
  })
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "C:/Users/javip/Documents/DAW/despliegue/hospital-mio/index.html"
  content_type = "text/html"
  acl = "public-read"
}

resource "aws_s3_object" "styles" {
  bucket = aws_s3_bucket.bucket.id
  key    = "estilos.css"
  source = "C:/Users/javip/Documents/DAW/despliegue/hospital-mio/estilos.css"
  content_type = "text/css"
  acl = "public-read"
}

resource "aws_s3_object" "imagen1" {
  bucket = aws_s3_bucket.bucket.id
  key    = "hospital.webp"
  source = "C:/Users/javip/Documents/DAW/despliegue/hospital-mio/hospital.webp"
  content_type = "image/webp"
  acl = "public-read"
}

resource "aws_s3_object" "imagen2" {
  bucket = aws_s3_bucket.bucket.id
  key    = "medico.webp"
  source = "C:/Users/javip/Documents/DAW/despliegue/hospital-mio/medico.webp"
  content_type = "image/webp"
  acl = "public-read"
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.bucket_website.website_endpoint
}
