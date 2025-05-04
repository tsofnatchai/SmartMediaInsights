#analyze image → send to Kinesis
import boto3, json,os

rek = boto3.client('rekognition')
kinesis = boto3.client('kinesis')
stream_name = os.environ.get("KINESIS_STREAM_NAME", "dev-events")

def lambda_handler(event, context):
    # Get S3 object info from event
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    # Analyze image with Rekognition
    response = rek.detect_labels(
        Image={'S3Object': {'Bucket': bucket, 'Name': key}},
        MaxLabels=5
    )

    labels = [label['Name'] for label in response['Labels']]

    # Send to Kinesis
    kinesis.put_record(
        StreamName=stream_name,
        Data=json.dumps({
            'id': key,
            'labels': labels
        }),
        PartitionKey=key
    )

    return { 'status': 'ok', 'labels': labels }
