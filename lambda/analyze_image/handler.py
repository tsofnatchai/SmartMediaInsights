#analyze image → send to Kinesis
import boto3, json,os

rek = boto3.client('rekognition')
kinesis = boto3.client('kinesis')
stream_name = os.environ.get("KINESIS_STREAM_NAME", "dev-events")

def lambda_handler(event, context):
    try:
        print("=== RAW EVENT ===")
        print(json.dumps(event, indent=2))  # Always log raw event

        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        response = rek.detect_labels(
            Image={'S3Object': {'Bucket': bucket, 'Name': key}},
            MaxLabels=5
        )
        labels = [label['Name'] for label in response['Labels']]

        kinesis.put_record(
            StreamName=stream_name,
            Data=json.dumps({'id': key, 'labels': labels}),
            PartitionKey=key
        )

        print(f"Processed {key}, labels: {labels}")
        return { 'status': 'ok', 'labels': labels }

    except Exception as e:
        import traceback
        print("=== ERROR OCCURRED ===")
        traceback.print_exc()  # Print full traceback
        raise


