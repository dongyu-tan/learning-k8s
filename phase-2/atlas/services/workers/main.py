import os
import json
import boto3
from datetime import datetime, timezone

import psycopg
from psycopg import sql
from psycopg.rows import dict_row

DB_CONN_STRING = os.environ["DATABASE_URL"]
S3_BUCKET = os.environ["S3_BUCKET"]


def get_sources(conn):
    with conn.cursor(row_factory=dict_row) as cur:
        cur.execute(
            """
            SELECT
                id,
                name,
                table_name,
                timestamp_column,
                expected_frequency_minutes
            FROM sources
            ORDER BY id
            """
        )
        return cur.fetchall()


def check_freshness(conn, source):
    query = sql.SQL("SELECT MAX({timestamp_column}) FROM {table_name}").format(
        timestamp_column=sql.Identifier(source["timestamp_column"]),
        table_name=sql.Identifier(source["table_name"]),
    )

    with conn.cursor() as cur:
        cur.execute(query)
        latest_data_at = cur.fetchone()[0]

    if latest_data_at is None:
        return {
            "source_id": source["id"],
            "latest_data_at": None,
            "lag_minutes": None,
            "status": "no_data",
        }

    if latest_data_at.tzinfo is None:
        latest_data_at = latest_data_at.replace(tzinfo=timezone.utc)

    lag = datetime.now(timezone.utc) - latest_data_at.astimezone(timezone.utc)
    lag_minutes = int(lag.total_seconds() // 60)
    if lag_minutes <= source["expected_frequency_minutes"]:
        status = "ok" 
    else:
        status = "stale"

    return {
        "source_id": source["id"],
        "latest_data_at": latest_data_at,
        "lag_minutes": lag_minutes,
        "status": status,
    }


def save_result(conn, result):
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO check_results (
                source_id,
                latest_data_at,
                lag_minutes,
                status
            )
            VALUES (%s, %s, %s, %s)
            """,
            (
                result["source_id"],
                result["latest_data_at"],
                result["lag_minutes"],
                result["status"],
            ),
        )
    conn.commit()


def serialize_report_value(value):
    if isinstance(value, datetime):
        return value.isoformat()
    raise TypeError(
        f"Object of type {type(value).__name__} is not JSON serializable"
    )


def upload_report(results):
    s3 = boto3.client("s3")
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d/%H-%M")
    key = f"reports/{timestamp}.json"
    s3.put_object(
        Bucket=S3_BUCKET,
        Key=key,
        Body=json.dumps(results, default=serialize_report_value),
    )


def main():
    conn = psycopg.connect(DB_CONN_STRING)
    try:
        sources = get_sources(conn)

        results = []
        for source in sources:
            result = check_freshness(conn, source)
            save_result(conn, result)
            results.append(result)

        upload_report(results)
    finally:
        conn.close()

if __name__ == "__main__":
    main()
