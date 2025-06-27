# Capstone 2: Serverless Translation Pipeline on AWS

This project is a serverless solution for real-time translation of text using AWS services. The architecture automatically translates text data uploaded to an S3 bucket and stores the translated result in another bucket using AWS Lambda and Amazon Translate.

---

## 🚀 Features

- ✅ Serverless architecture using AWS Lambda
- ✅ Real-time file processing via S3 bucket trigger
- ✅ Language auto-detection with Amazon Translate
- ✅ Output translation stored in a separate S3 bucket
- ✅ Infrastructure provisioned using Terraform
- ✅ Environment variables and permissions managed securely

---

## 🧱 Architecture Overview

1. **Input JSON File** is uploaded to `input` S3 bucket.
2. **S3 Event Notification** triggers the Lambda function.
3. **Lambda** reads the file, uses **Amazon Translate** to translate text.
4. **Translated Output** is saved in the `output` S3 bucket.
5. **CloudWatch Logs** track execution.

---

## 🛠️ Tech Stack

- **AWS Lambda** (Python 3.11)
- **Amazon S3** for input/output
- **Amazon Translate** for translation
- **Amazon Comprehend** for language detection (`auto`)
- **Terraform** for infrastructure as code

---

## 📁 File Structure

capstone2/
├── main.tf # Terraform configuration
├── lambda_function.py # Lambda source code
├── lambda_package.zip # Zipped package for Lambda
├── README.md # This file
└── .gitignore # Git ignore file
