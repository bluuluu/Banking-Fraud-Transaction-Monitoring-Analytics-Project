-- Data quality checks for the fraud monitoring database.
-- Each query returns rows only when a potential issue exists, except the final summary.

-- 1. Duplicate transaction IDs.
SELECT transaction_id, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 2. Transactions with invalid or missing amounts.
SELECT transaction_id, amount
FROM transactions
WHERE amount IS NULL OR amount <= 0;

-- 3. Transactions missing required timestamps.
SELECT transaction_id, transaction_ts
FROM transactions
WHERE transaction_ts IS NULL;

-- 4. Transactions linked to inactive or missing accounts.
SELECT
    t.transaction_id,
    t.account_id,
    a.account_status
FROM transactions t
LEFT JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL OR a.account_status <> 'Open';

-- 5. Accounts linked to missing customers.
SELECT
    a.account_id,
    a.customer_id
FROM accounts a
LEFT JOIN customers c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 6. Alerts linked to missing transactions.
SELECT
    fa.alert_id,
    fa.transaction_id
FROM fraud_alerts fa
LEFT JOIN transactions t ON fa.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;

-- 7. Cases linked to missing alerts.
SELECT
    cr.case_id,
    cr.alert_id
FROM case_reviews cr
LEFT JOIN fraud_alerts fa ON cr.alert_id = fa.alert_id
WHERE fa.alert_id IS NULL;

-- 8. Closed cases without a close timestamp or disposition.
SELECT
    case_id,
    case_status,
    case_closed_ts,
    disposition
FROM case_reviews
WHERE case_status = 'Closed'
  AND (case_closed_ts IS NULL OR disposition IS NULL);

-- 9. Cases closed before they were opened.
SELECT
    case_id,
    case_opened_ts,
    case_closed_ts
FROM case_reviews
WHERE case_closed_ts IS NOT NULL
  AND case_closed_ts < case_opened_ts;

-- 10. Alerts with risk scores outside the expected range.
SELECT
    alert_id,
    risk_score
FROM fraud_alerts
WHERE risk_score < 0 OR risk_score > 100;

-- 11. Country code format issues.
SELECT 'customers' AS table_name, customer_id AS record_id, country_code
FROM customers
WHERE country_code !~ '^[A-Z]{2}$'
UNION ALL
SELECT 'merchants' AS table_name, merchant_id AS record_id, country_code
FROM merchants
WHERE country_code !~ '^[A-Z]{2}$'
UNION ALL
SELECT 'transactions' AS table_name, transaction_id AS record_id, country_code
FROM transactions
WHERE country_code !~ '^[A-Z]{2}$';

-- 12. Summary record counts.
SELECT 'customers' AS table_name, COUNT(*) AS record_count FROM customers
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'fraud_alerts', COUNT(*) FROM fraud_alerts
UNION ALL
SELECT 'case_reviews', COUNT(*) FROM case_reviews
ORDER BY table_name;
