#!/usr/bin/env bash
set -euo pipefail

DATABASE_URL="${DATABASE_URL:-postgresql+psycopg2:///banking_fraud_monitoring}"

python3 src/data_cleaning.py --database-url "$DATABASE_URL"
python3 src/feature_engineering.py
python3 src/fraud_scoring.py
python3 src/generate_portfolio_assets.py
