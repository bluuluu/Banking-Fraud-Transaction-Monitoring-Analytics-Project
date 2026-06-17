-- Reusable views for Power BI or analyst reporting.
-- Run after sql/01_schema.sql and sql/02_seed_data.sql.

CREATE OR REPLACE VIEW vw_transaction_risk_features AS
WITH account_history AS (
    SELECT
        t.transaction_id,
        t.account_id,
        AVG(t.amount) OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_ts
            ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING
        ) AS prior_avg_amount,
        STDDEV_SAMP(t.amount) OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_ts
            ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING
        ) AS prior_stddev_amount,
        COUNT(*) OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_ts
            RANGE BETWEEN INTERVAL '1 hour' PRECEDING AND CURRENT ROW
        ) AS transactions_last_hour,
        COUNT(*) OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_ts
            RANGE BETWEEN INTERVAL '24 hours' PRECEDING AND CURRENT ROW
        ) AS transactions_last_24h
    FROM transactions t
)
SELECT
    t.transaction_id,
    t.transaction_ts,
    DATE_TRUNC('day', t.transaction_ts)::date AS transaction_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_segment,
    c.kyc_risk_rating,
    a.account_id,
    a.account_type,
    t.merchant_id,
    COALESCE(m.merchant_name, 'Peer / Bank Transfer') AS merchant_name,
    COALESCE(m.merchant_category, 'Transfer') AS merchant_category,
    COALESCE(m.merchant_risk_rating, 'Low') AS merchant_risk_rating,
    t.amount,
    t.currency_code,
    t.transaction_type,
    t.transaction_channel,
    t.transaction_status,
    t.country_code AS transaction_country,
    c.country_code AS customer_country,
    t.city AS transaction_city,
    t.device_id,
    t.is_international,
    t.is_card_present,
    CASE
        WHEN ah.prior_stddev_amount IS NULL OR ah.prior_stddev_amount = 0 THEN NULL
        ELSE ROUND(((t.amount - ah.prior_avg_amount) / ah.prior_stddev_amount)::numeric, 2)
    END AS amount_z_score,
    ah.prior_avg_amount,
    ah.transactions_last_hour,
    ah.transactions_last_24h,
    CASE WHEN t.country_code <> c.country_code THEN TRUE ELSE FALSE END AS country_mismatch_flag,
    CASE WHEN EXTRACT(HOUR FROM t.transaction_ts) BETWEEN 0 AND 5 THEN TRUE ELSE FALSE END AS night_transaction_flag,
    CASE WHEN COALESCE(m.merchant_risk_rating, 'Low') = 'High' THEN TRUE ELSE FALSE END AS high_risk_merchant_flag,
    CASE WHEN ah.prior_avg_amount IS NOT NULL AND t.amount >= ah.prior_avg_amount * 3 THEN TRUE ELSE FALSE END AS sudden_spend_increase_flag,
    CASE WHEN ah.transactions_last_hour >= 3 THEN TRUE ELSE FALSE END AS velocity_flag,
    t.fraud_label
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
LEFT JOIN account_history ah ON t.transaction_id = ah.transaction_id;

CREATE OR REPLACE VIEW vw_fraud_overview_daily AS
SELECT
    DATE_TRUNC('day', t.transaction_ts)::date AS transaction_date,
    COUNT(*) AS transaction_count,
    SUM(t.amount) AS total_transaction_amount,
    COUNT(*) FILTER (WHERE fa.alert_id IS NOT NULL) AS flagged_transaction_count,
    COUNT(*) FILTER (WHERE t.fraud_label IS TRUE) AS confirmed_fraud_transaction_count,
    ROUND(
        COUNT(*) FILTER (WHERE fa.alert_id IS NOT NULL)::numeric / NULLIF(COUNT(*), 0),
        4
    ) AS alert_rate,
    ROUND(
        COUNT(*) FILTER (WHERE t.fraud_label IS TRUE)::numeric / NULLIF(COUNT(*), 0),
        4
    ) AS fraud_rate,
    ROUND(AVG(fa.risk_score), 2) AS avg_alert_risk_score
FROM transactions t
LEFT JOIN fraud_alerts fa ON t.transaction_id = fa.transaction_id
GROUP BY DATE_TRUNC('day', t.transaction_ts)::date;

CREATE OR REPLACE VIEW vw_customer_risk_profile AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.country_code,
    c.city,
    c.customer_segment,
    c.kyc_risk_rating,
    COUNT(DISTINCT a.account_id) AS account_count,
    COUNT(t.transaction_id) AS transaction_count,
    COALESCE(SUM(t.amount), 0) AS total_transaction_amount,
    COUNT(fa.alert_id) AS alert_count,
    COUNT(t.transaction_id) FILTER (WHERE t.fraud_label IS TRUE) AS confirmed_fraud_count,
    ROUND(AVG(fa.risk_score), 2) AS avg_alert_risk_score,
    MAX(t.transaction_ts) AS latest_transaction_ts
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
LEFT JOIN fraud_alerts fa ON t.transaction_id = fa.transaction_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.country_code, c.city,
    c.customer_segment, c.kyc_risk_rating;

CREATE OR REPLACE VIEW vw_merchant_risk_summary AS
SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.country_code,
    m.city,
    m.merchant_risk_rating,
    m.is_online,
    COUNT(t.transaction_id) AS transaction_count,
    COALESCE(SUM(t.amount), 0) AS total_transaction_amount,
    COUNT(fa.alert_id) AS alert_count,
    COUNT(t.transaction_id) FILTER (WHERE t.fraud_label IS TRUE) AS confirmed_fraud_count,
    ROUND(AVG(fa.risk_score), 2) AS avg_alert_risk_score
FROM merchants m
LEFT JOIN transactions t ON m.merchant_id = t.merchant_id
LEFT JOIN fraud_alerts fa ON t.transaction_id = fa.transaction_id
GROUP BY
    m.merchant_id, m.merchant_name, m.merchant_category, m.country_code,
    m.city, m.merchant_risk_rating, m.is_online;

CREATE OR REPLACE VIEW vw_case_review_tracker AS
SELECT
    cr.case_id,
    fa.alert_id,
    t.transaction_id,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(m.merchant_name, 'Peer / Bank Transfer') AS merchant_name,
    t.transaction_ts,
    t.amount,
    t.currency_code,
    fa.alert_type,
    fa.alert_severity,
    fa.risk_score,
    fa.alert_status,
    cr.assigned_analyst,
    cr.case_opened_ts,
    cr.case_closed_ts,
    cr.case_status,
    cr.disposition,
    CASE
        WHEN cr.case_closed_ts IS NULL THEN NULL
        ELSE ROUND(EXTRACT(EPOCH FROM (cr.case_closed_ts - cr.case_opened_ts)) / 3600, 2)
    END AS hours_to_close,
    cr.recovery_amount
FROM case_reviews cr
JOIN fraud_alerts fa ON cr.alert_id = fa.alert_id
JOIN transactions t ON fa.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id;
