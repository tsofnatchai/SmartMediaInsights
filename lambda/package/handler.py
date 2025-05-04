#store result in RDS
import boto3, json, pymysql, os
import base64

comprehend = boto3.client('comprehend')

rds_conn = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASSWORD'],
    db=os.environ['DB_NAME']
)

def lambda_handler(event, context):
    for record in event['Records']:
        data_b64 = record['kinesis']['data']
        payload = json.loads(base64.b64decode(data_b64).decode("utf-8"))
        image_id = payload['id']
        labels = payload['labels']

        # Use Comprehend to analyze labels as text
        text = ' '.join(labels)
        sentiment = comprehend.detect_sentiment(Text=text, LanguageCode='en')['Sentiment']

        with rds_conn.cursor() as cur:
            cur.execute("""
                INSERT INTO analysis_results (id, label, score)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE label=%s, score=%s
            """, (image_id, sentiment, 0.9, sentiment, 0.9))

        rds_conn.commit()

    return {'status': 'processed'}
