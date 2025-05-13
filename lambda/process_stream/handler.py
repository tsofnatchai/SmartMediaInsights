# Store result in RDS
import boto3, json, pymysql, os, base64
from pymysql.err import OperationalError

comprehend = boto3.client('comprehend')




def connect_to_rds():
    try:
        conn = pymysql.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            db=os.environ['DB_NAME'],
            connect_timeout=5
        )
        print("RDS connection established.")
        return conn
    except OperationalError as e:
        print(f"Failed to connect to RDS: {e}")
        raise e

def lambda_handler(event, context):
    rds_conn = connect_to_rds()

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

    rds_conn.close()
    return {'status': 'processed'}

