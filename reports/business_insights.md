# Fraud Monitoring Business Insights

## Executive Summary

- Reviewed 35 transactions with $55,279.57 in total transaction value.
- Flagged 12 high-risk transactions for analyst review.
- Identified 13 confirmed fraud-labelled transactions, equal to a 37.1% fraud rate in the synthetic sample.
- Highest average customer risk: Ethan Brown with an average score of 64.64.
- Highest average merchant category risk: Luxury Goods with an average score of 100.00.

## Key Observations

- International card-not-present transactions drive a large share of high-risk alerts.
- High-risk merchant categories such as Crypto Exchange, Gaming, Gift Cards, and Luxury Goods produce elevated risk scores.
- Velocity, new merchant behavior, and sudden spending increases are useful explainable fraud indicators.
- The Isolation Forest score helps surface unusual transactions, while the rule-based score keeps analyst explanations clear.

## Recommended Monitoring Actions

- Prioritize Critical and High risk bands for same-day review.
- Monitor customers with repeated cross-border card-not-present transactions.
- Add stricter controls for high-risk merchant categories and new-device transactions.
- Track false positives once analyst outcomes are available to tune rule thresholds.

## Generated Visuals

- `reports/screenshots/risk_band_distribution.png`
- `reports/screenshots/merchant_category_risk.png`
- `reports/screenshots/daily_fraud_trend.png`
- `reports/screenshots/top_high_risk_transactions.png`
