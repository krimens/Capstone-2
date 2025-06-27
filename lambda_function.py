import json
import boto3
import os
import urllib.parse

s3 = boto3.client('s3')
translate = boto3.client('translate')
output_bucket = os.environ.get('OUTPUT_BUCKET')

def lambda_handler(event, context):
    print("Event:", json.dumps(event))
    for record in event['Records']:
        src_bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        
        response = s3.get_object(Bucket=src_bucket, Key=key)
        content = response['Body'].read().decode('utf-8')
        data = json.loads(content)

        translated = {}
        for item_id, text in data.items():
            result = translate.translate_text(Text=text, SourceLanguageCode="auto", TargetLanguageCode="es")
            translated[item_id] = result['TranslatedText']

        translated_key = f"translated_{os.path.basename(key)}"
        s3.put_object(
            Bucket=output_bucket,
            Key=translated_key,
            Body=json.dumps(translated),
            ContentType='application/json'
        )
        print(f"Translated file saved to {output_bucket}/{translated_key}")
