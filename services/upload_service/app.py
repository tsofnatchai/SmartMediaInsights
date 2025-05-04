from flask import Flask, request, jsonify
import boto3, os

app = Flask(__name__)
s3 = boto3.client('s3')
BUCKET = os.getenv('UPLOADS_BUCKET')

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files['file']
    key = file.filename
    s3.upload_fileobj(file, BUCKET, key)
    return jsonify({'key': key})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)