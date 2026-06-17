# Banking Fraud & Transaction Monitoring Analytics

An analytics project for monitoring bank transactions, identifying suspicious activity, and supporting fraud-risk investigation workflows. The project is designed around a realistic data analyst and risk analytics stack: SQL, PostgreSQL, Python, Power BI, Excel, and data quality checks.

## Project Overview

This project models a fraud and transaction monitoring workflow used by banking, compliance, AML, risk analytics, and financial crime teams. The goal is to analyze customer and transaction behavior, create fraud-risk indicators, detect unusual activity, and present the results through dashboards and investigation-ready outputs.

The project is intended to demonstrate:

- Transaction monitoring and fraud-risk analytics
- SQL querying, joins, aggregations, CTEs, and window functions
- Python-based data cleaning, feature engineering, and anomaly detection
- Data quality validation and reconciliation checks
- Power BI dashboarding for risk and compliance stakeholders
- Business-ready reporting for case review and exception tracking

## Recommended Tech Stack

- **SQL / PostgreSQL**: relational data storage, joins, aggregations, time-window analysis, and validation queries
- **Python**: data cleaning, feature engineering, scoring, and anomaly detection
- **Pandas / NumPy**: data transformation and analytical calculations
- **scikit-learn**: anomaly detection using models such as Isolation Forest
- **Power BI**: interactive dashboards and risk reporting
- **Excel / Power Query**: business-user review, reconciliation, and exception summaries
- **Great Expectations or custom checks**: data quality testing and validation

## Proposed Data Model

The project can be organized around the following core tables:

- `customers`: customer demographic and onboarding information
- `accounts`: customer account details and account status
- `transactions`: transaction-level activity across channels and merchants
- `merchants`: merchant category, location, and risk attributes
- `fraud_alerts`: rule-based and model-based fraud alerts
- `case_reviews`: analyst review outcomes, dispositions, and notes

## Fraud Risk Features

Example features that can be engineered for transaction monitoring:

- Transaction amount z-score
- Transactions per hour
- Spending velocity
- Merchant risk score
- Country mismatch flag
- Sudden spending increase flag
- New merchant flag
- Night transaction flag
- Customer historical average spend
- Distance from normal customer behavior
- Channel or location mismatch indicator

## Analytics Workflow

1. Load customer, account, merchant, transaction, alert, and case review data into PostgreSQL.
2. Profile the data using SQL and Python to identify missing values, duplicates, invalid records, and unusual distributions.
3. Build SQL queries for transaction monitoring metrics, rolling customer behavior, and investigation views.
4. Use Python to clean data, engineer fraud-risk features, and calculate risk scores.
5. Apply rule-based detection and optional anomaly detection with Isolation Forest.
6. Export clean analytical tables for Power BI and Excel reporting.
7. Build dashboards for fraud trends, flagged transactions, customer risk, merchant risk, and case review tracking.

## Example Risk Rules

Possible fraud-monitoring rules include:

- High-value transaction above a defined customer-specific threshold
- Multiple transactions in a short time window
- Transaction from a new country or high-risk region
- Transaction from a merchant category not previously used by the customer
- Rapid increase from historical average spending
- Night-time or unusual-hour transaction
- Duplicate or near-duplicate transaction

## Dashboard Pages

Suggested Power BI report pages:

- **Fraud Overview**: total volume, flagged transactions, fraud rate, and trend KPIs
- **High-Risk Transactions**: transaction-level monitoring and investigation queue
- **Customer Risk Profiles**: customer behavior, risk score, and alert history
- **Merchant Risk Analysis**: merchant-level alert concentration and risk trends
- **Geographic Risk Map**: fraud activity by country, region, or transaction location
- **Case Review Tracker**: analyst review status, false positives, confirmed fraud, and open cases
- **Monthly Fraud Trends**: month-over-month risk patterns and detection performance

## Key Metrics

- Total transaction volume
- Total transaction value
- Number of flagged transactions
- Fraud rate
- False positive rate
- Average transaction risk score
- High-risk customers
- High-risk merchants
- Fraud by country or region
- Fraud by transaction channel
- Monthly fraud trend
- Case review completion rate

## Data Quality Checks

Recommended validation checks:

- No missing transaction IDs
- No duplicate transaction IDs
- No negative transaction amounts
- Valid customer IDs on all transactions
- Valid account IDs on all transactions
- Valid merchant IDs where applicable
- Valid transaction timestamps
- Valid country and currency codes
- No transaction dates in impossible ranges
- Merchant category values match approved categories

## Suggested Repository Structure

```text
.
|-- data/
|   |-- raw/
|   |-- processed/
|   `-- reference/
|-- notebooks/
|   |-- 01_data_profiling.ipynb
|   |-- 02_feature_engineering.ipynb
|   `-- 03_fraud_scoring.ipynb
|-- sql/
|   |-- 01_schema.sql
|   |-- 02_seed_data.sql
|   |-- 03_dashboard_views.sql
|   |-- 04_transaction_monitoring_queries.sql
|   |-- 05_data_quality_checks.sql
|   `-- run_all.sql
|-- powerbi/
|   `-- fraud_monitoring_dashboard.pbix
|-- reports/
|   `-- case_review_summary.xlsx
|-- src/
|   |-- data_cleaning.py
|   |-- feature_engineering.py
|   `-- fraud_scoring.py
`-- README.md
```

## Setup Notes

This repository includes PostgreSQL scripts under `sql/` for the database schema, synthetic sample data, dashboard views, data quality checks, and analyst queries.

To load the SQL project into PostgreSQL:

```bash
createdb banking_fraud_monitoring
psql -d banking_fraud_monitoring -f sql/run_all.sql
```

Then run the analytical query and data quality scripts:

```bash
psql -d banking_fraud_monitoring -f sql/04_transaction_monitoring_queries.sql
psql -d banking_fraud_monitoring -f sql/05_data_quality_checks.sql
```

A typical implementation would follow these steps:

1. Create the PostgreSQL database and tables.
2. Load raw or synthetic banking transaction data.
3. Run SQL profiling and data quality checks.
4. Use Python notebooks or scripts to engineer fraud-risk features.
5. Generate risk scores and alert outputs.
6. Connect Power BI to the processed tables or exported CSV files.
7. Build and publish the fraud monitoring dashboard.

## Resume Summary

**Fraud Risk & Transaction Monitoring Analytics Platform**  
Built an end-to-end fraud analytics project using SQL, Python, PostgreSQL, Power BI, and Excel to monitor transaction patterns, flag anomalous activity, engineer fraud-risk indicators, validate data quality, and support investigation workflows for suspicious banking transactions.

## Project Status

Initial README and SQL layer created. The project now includes a PostgreSQL schema, synthetic banking transaction data, dashboard-ready views, transaction monitoring queries, and data quality checks. Python notebooks, Excel outputs, and Power BI dashboard assets can be added next.
