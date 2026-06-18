"""Extract and clean transaction monitoring data from PostgreSQL.

Default output:
    data/processed/clean_transactions.csv
"""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine


DEFAULT_DATABASE_URL = "postgresql+psycopg2:///banking_fraud_monitoring"
DEFAULT_OUTPUT_PATH = Path("data/processed/clean_transactions.csv")


EXTRACT_QUERY = """
SELECT
    t.transaction_id,
    t.transaction_ts,
    t.amount,
    t.currency_code,
    t.transaction_type,
    t.transaction_channel,
    t.transaction_status,
    t.country_code AS transaction_country,
    t.city AS transaction_city,
    t.device_id,
    t.ip_address::text AS ip_address,
    t.is_international,
    t.is_card_present,
    t.fraud_label,
    a.account_id,
    a.account_type,
    a.account_status,
    a.current_balance,
    a.currency_code AS account_currency,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country_code AS customer_country,
    c.city AS customer_city,
    c.customer_segment,
    c.kyc_risk_rating,
    c.onboarding_date,
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.country_code AS merchant_country,
    m.city AS merchant_city,
    m.merchant_risk_rating,
    m.is_online AS merchant_is_online
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
ORDER BY t.transaction_ts, t.transaction_id;
"""


def load_transactions(database_url: str) -> pd.DataFrame:
    """Load denormalized transaction records from PostgreSQL."""
    engine = create_engine(database_url)
    with engine.connect() as connection:
        return pd.read_sql(EXTRACT_QUERY, connection)


def clean_transactions(df: pd.DataFrame) -> pd.DataFrame:
    """Apply portfolio-friendly cleaning rules to transaction data."""
    cleaned = df.copy()

    cleaned["transaction_ts"] = pd.to_datetime(cleaned["transaction_ts"], errors="coerce")
    cleaned["onboarding_date"] = pd.to_datetime(cleaned["onboarding_date"], errors="coerce")
    cleaned["amount"] = pd.to_numeric(cleaned["amount"], errors="coerce")
    cleaned["current_balance"] = pd.to_numeric(cleaned["current_balance"], errors="coerce")

    text_columns = [
        "currency_code",
        "transaction_type",
        "transaction_channel",
        "transaction_status",
        "transaction_country",
        "transaction_city",
        "account_type",
        "account_status",
        "account_currency",
        "first_name",
        "last_name",
        "customer_country",
        "customer_city",
        "customer_segment",
        "kyc_risk_rating",
        "merchant_name",
        "merchant_category",
        "merchant_country",
        "merchant_city",
        "merchant_risk_rating",
    ]
    for column in text_columns:
        if column in cleaned.columns:
            cleaned[column] = cleaned[column].fillna("").astype(str).str.strip()

    cleaned["merchant_name"] = cleaned["merchant_name"].replace("", "Peer / Bank Transfer")
    cleaned["merchant_category"] = cleaned["merchant_category"].replace("", "Transfer")
    cleaned.loc[cleaned["merchant_country"].eq(""), "merchant_country"] = cleaned.loc[
        cleaned["merchant_country"].eq(""), "transaction_country"
    ]
    cleaned.loc[cleaned["merchant_city"].eq(""), "merchant_city"] = cleaned.loc[
        cleaned["merchant_city"].eq(""), "transaction_city"
    ]
    cleaned["merchant_risk_rating"] = cleaned["merchant_risk_rating"].replace("", "Low")
    cleaned["merchant_is_online"] = cleaned["merchant_is_online"].astype("boolean").fillna(False).astype(bool)
    cleaned["fraud_label"] = cleaned["fraud_label"].fillna(False).astype(bool)
    cleaned["is_international"] = cleaned["is_international"].fillna(False).astype(bool)
    cleaned["is_card_present"] = cleaned["is_card_present"].fillna(False).astype(bool)

    cleaned["customer_name"] = (
        cleaned["first_name"].fillna("").astype(str).str.strip()
        + " "
        + cleaned["last_name"].fillna("").astype(str).str.strip()
    ).str.strip()

    cleaned = cleaned.drop_duplicates(subset=["transaction_id"], keep="first")
    cleaned = cleaned.dropna(subset=["transaction_id", "transaction_ts", "account_id", "customer_id", "amount"])
    cleaned = cleaned[cleaned["amount"] > 0].copy()

    cleaned["transaction_date"] = cleaned["transaction_ts"].dt.date
    cleaned["transaction_hour"] = cleaned["transaction_ts"].dt.hour
    cleaned["days_since_onboarding"] = (
        cleaned["transaction_ts"].dt.normalize() - cleaned["onboarding_date"].dt.normalize()
    ).dt.days

    ordered_columns = [
        "transaction_id",
        "transaction_ts",
        "transaction_date",
        "transaction_hour",
        "amount",
        "currency_code",
        "transaction_type",
        "transaction_channel",
        "transaction_status",
        "transaction_country",
        "transaction_city",
        "device_id",
        "ip_address",
        "is_international",
        "is_card_present",
        "account_id",
        "account_type",
        "account_status",
        "current_balance",
        "account_currency",
        "customer_id",
        "customer_name",
        "customer_country",
        "customer_city",
        "customer_segment",
        "kyc_risk_rating",
        "days_since_onboarding",
        "merchant_id",
        "merchant_name",
        "merchant_category",
        "merchant_country",
        "merchant_city",
        "merchant_risk_rating",
        "merchant_is_online",
        "fraud_label",
    ]
    return cleaned[ordered_columns].sort_values(["transaction_ts", "transaction_id"]).reset_index(drop=True)


def write_output(df: pd.DataFrame, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Clean banking transaction data from PostgreSQL.")
    parser.add_argument("--database-url", default=DEFAULT_DATABASE_URL, help="SQLAlchemy PostgreSQL connection URL.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_PATH, help="Output CSV path.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    raw = load_transactions(args.database_url)
    cleaned = clean_transactions(raw)
    write_output(cleaned, args.output)
    print(f"Wrote {len(cleaned):,} cleaned transactions to {args.output}")


if __name__ == "__main__":
    main()
