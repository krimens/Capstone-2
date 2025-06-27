provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "capstone2-input-bucket-024419"
  force_destroy = true
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "capstone2-output-bucket-024419"
  force_destroy = true
}

resource "aws_iam_role" "lambda_role" {
  name = "translate_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_access" {
  name   = "LambdaS3Access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.input_bucket.arn}/*"
      },
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.output_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_s3_attach" {
  name       = "attach-lambda-s3"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

resource "aws_iam_policy" "comprehend_detect" {
  name   = "AllowComprehendDetectLanguage"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "comprehend:DetectDominantLanguage",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_comprehend_detect" {
  name       = "lambda-allow-comprehend-detect"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.comprehend_detect.arn
}



 resource "aws_iam_policy" "translate_text_only" {
  name   = "TranslateTextOnly"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "translate:TranslateText",
      Effect = "Allow",
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy_attachment" "minimal_translate_attach" {
  name       = "translate-text-only"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.translate_text_only.arn
}

 

resource "aws_lambda_function" "translate_function" {
  filename         = "lambda_package.zip"
  function_name    = "lambda_function"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256("lambda_package.zip")
  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

 

resource "aws_s3_bucket_notification" "input_trigger" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.translate_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

 


 
 resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.translate_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}