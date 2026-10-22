resource "aws_cloudtrail" "example" {
  name = "madlab-trail"
  s3_bucket_name = "purple-lab"
  is_multi_region_trail = true
  enable_log_file_validation = true

  depends_on = [ aws_s3_bucket.example ]
}

resource "aws_s3_bucket" "example" {
  bucket = "purple-bucket"
}