-- Analyst query examples for transaction monitoring.
-- Run after sql/03_dashboard_views.sql.

-- 1. Highest-risk open alerts for analyst review.
SELECT
    fa.alert_id,
    fa.alert_created_ts,
    fa.alert_severity,
    fa.risk_score,
    fa.alert_status,
    trf.customer_name,
    trf.account_id,
    trf.transaction_id,
    trf.transaction_ts,
    trf.amount,
    trf.currency_code,
    trf.merchant_name,
    trf.merchant_category,
    trf.transaction_country,
    trf.country_mismatch_flag,
    trf.night_transaction_flag,
    trf.velocity_flag
FROM fraud_alerts fa
JOIN vw_transaction_risk_features trf
    ON fa.transaction_id = trf.transaction_id
WHERE fa.alert_status IN ('Open', 'In Review')
ORDER BY fa.risk_score DESC, fa.alert_created_ts;

-- 2. Transactions that hit multiple rule-based risk indicators.
SELECT
    transaction_id,
    transaction_ts,
    customer_name,
    amount,
    currency_code,
    merchant_name,
    merchant_category,
    transaction_channel,
    transactions_last_hour,
    country_mismatch_flag,
    night_transaction_flag,
    high_risk_merchant_flag,
    sudden_spend_increase_flag,
    velocity_flag,
    (
        country_mismatch_flag::int
        + night_transaction_flag::int
        + high_risk_merchant_flag::int
        + sudden_spend_increase_flag::int
        + velocity_flag::int
    ) AS triggered_rule_count
FROM vw_transaction_risk_features
WHERE (
    country_mismatch_flag::int
    + night_transaction_flag::int
    + high_risk_merchant_flag::int
    + sudden_spend_increase_flag::int
    + velocity_flag::int
) >= 2
ORDER BY triggered_rule_count DESC, amount DESC;

-- 3. Customer-level fraud and alert concentration.
SELECT
    customer_id,
    customer_name,
    customer_segment,
    kyc_risk_rating,
    transaction_count,
    total_transaction_amount,
    alert_count,
    confirmed_fraud_count,
    avg_alert_risk_score,
    ROUND(alert_count::numeric / NULLIF(transaction_count, 0), 4) AS customer_alert_rate
FROM vw_customer_risk_profile
ORDER BY alert_count DESC, avg_alert_risk_score DESC NULLS LAST;

-- 4. Merchant categories with the highest fraud exposure.
SELECT
    merchant_category,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    COUNT(*) FILTER (WHERE fraud_label IS TRUE) AS confirmed_fraud_count,
    ROUND(COUNT(*) FILTER (WHERE fraud_label IS TRUE)::numeric / NULLIF(COUNT(*), 0), 4) AS fraud_rate
FROM vw_transaction_risk_features
GROUP BY merchant_category
ORDER BY confirmed_fraud_count DESC, fraud_rate DESC, total_amount DESC;

-- 5. Cross-border card-not-present transactions.
SELECT
    transaction_id,
    transaction_ts,
    customer_name,
    customer_country,
    transaction_country,
    amount,
    currency_code,
    merchant_name,
    merchant_risk_rating,
    device_id,
    fraud_label
FROM vw_transaction_risk_features
WHERE is_international = TRUE
  AND is_card_present = FALSE
ORDER BY amount DESC;

-- 6. Rapid repeat transactions by account and merchant.
WITH ordered_transactions AS (
    SELECT
        t.*,
        LAG(t.transaction_ts) OVER (
            PARTITION BY t.account_id, t.merchant_id, t.amount
            ORDER BY t.transaction_ts
        ) AS prior_matching_transaction_ts
    FROM transactions t
)
SELECT
    ot.transaction_id,
    ot.account_id,
    ot.merchant_id,
    m.merchant_name,
    ot.amount,
    ot.transaction_ts,
    ot.prior_matching_transaction_ts,
    ROUND(EXTRACT(EPOCH FROM (ot.transaction_ts - ot.prior_matching_transaction_ts)) / 60, 2) AS minutes_since_prior_match
FROM ordered_transactions ot
LEFT JOIN merchants m ON ot.merchant_id = m.merchant_id
WHERE ot.prior_matching_transaction_ts IS NOT NULL
  AND ot.transaction_ts - ot.prior_matching_transaction_ts <= INTERVAL '30 minutes'
ORDER BY minutes_since_prior_match;

-- 7. Daily dashboard summary.
SELECT
    transaction_date,
    transaction_count,
    total_transaction_amount,
    flagged_transaction_count,
    confirmed_fraud_transaction_count,
    alert_rate,
    fraud_rate,
    avg_alert_risk_score
FROM vw_fraud_overview_daily
ORDER BY transaction_date;

-- 8. Case review performance by analyst.
SELECT
    assigned_analyst,
    COUNT(*) AS assigned_cases,
    COUNT(*) FILTER (WHERE case_status = 'Closed') AS closed_cases,
    COUNT(*) FILTER (WHERE disposition = 'Confirmed Fraud') AS confirmed_fraud_cases,
    ROUND(AVG(hours_to_close), 2) AS avg_hours_to_close,
    SUM(recovery_amount) AS total_recovery_amount
FROM vw_case_review_tracker
GROUP BY assigned_analyst
ORDER BY confirmed_fraud_cases DESC, assigned_cases DESC;
