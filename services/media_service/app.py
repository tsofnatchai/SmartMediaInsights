from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import boto3
import pymysql
import os

app = Flask(__name__)

# S3 client
s3 = boto3.client("s3")
bucket = os.getenv("UPLOAD_BUCKET")

# Create DB connection only when needed
def get_db_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME"),
        connect_timeout=5
    )

def ensure_table_exists(conn):
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS analysis_results (
                id VARCHAR(255) PRIMARY KEY,
                label VARCHAR(50),
                score FLOAT
            )
        """)
    conn.commit()

@app.route("/upload", methods=["POST"])
def upload_file():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file part"}), 400

        file = request.files["file"]
        if file.filename == "":
            return jsonify({"error": "No selected file"}), 400

        filename = secure_filename(file.filename)
        s3.upload_fileobj(file, bucket, filename)

        return jsonify({"status": "uploaded", "file": filename})

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/result", methods=["GET"])
def get_result():
    image_id = request.args.get("id")
    if not image_id:
        return jsonify({"error": "Missing id parameter"}), 400

    try:
        conn = get_db_connection()
        ensure_table_exists(conn)
        with conn.cursor() as cur:
            cur.execute("SELECT label, score FROM analysis_results WHERE id = %s", (image_id,))
            row = cur.fetchone()
        conn.close()

        if row:
            return jsonify({
                "id": image_id,
                "label": row[0],
                "score": row[1]
            })
        else:
            return jsonify({"error": "Result not found"}), 404

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
