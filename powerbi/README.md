# Power BI Dashboard Build Guide

Power BI Desktop is required to create the final `.pbix` dashboard file. Use the generated CSV outputs in `data/processed/` as the report data source.

## Data Sources

Import these files into Power BI:

- `data/processed/fraud_scores.csv`
- `data/processed/high_risk_transactions.csv`
- `data/processed/transaction_features.csv`
- `data/processed/clean_transactions.csv`

## Recommended Pages

1. **Fraud Overview**
   - KPI cards: total transactions, total transaction value, high-risk transactions, confirmed fraud, average risk score
   - Risk band distribution bar chart
   - Daily transaction and high-risk trend line chart

2. **High-Risk Transactions**
   - Table using `high_risk_transactions.csv`
   - Columns: transaction ID, customer, amount, merchant category, final risk score, risk band, recommended action
   - Slicers: risk band, merchant category, transaction country, transaction channel

3. **Customer Risk Profiles**
   - Customer-level table with transaction count, total amount, average risk score, high-risk count, confirmed fraud count
   - Bar chart of top customers by average risk score

4. **Merchant Risk Analysis**
   - Merchant category risk summary
   - Average risk score by merchant category
   - Confirmed fraud count by merchant category

5. **Transaction Monitoring Rules**
   - Rule flag counts
   - Matrix of risk flags by merchant category and transaction channel

6. **Case Review Tracker**
   - Analyst queue table using risk band and recommended action
   - Count of immediate review, same-day review, standard review, and monitor items

## Visual Assets

Reference chart images are available in `reports/screenshots/`:

- `risk_band_distribution.png`
- `merchant_category_risk.png`
- `daily_fraud_trend.png`
- `top_high_risk_transactions.png`
