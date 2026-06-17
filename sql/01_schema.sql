-- Banking Fraud & Transaction Monitoring Analytics
-- PostgreSQL schema

DROP VIEW IF EXISTS vw_case_review_tracker;
DROP VIEW IF EXISTS vw_customer_risk_profile;
DROP VIEW IF EXISTS vw_merchant_risk_summary;
DROP VIEW IF EXISTS vw_transaction_risk_features;
DROP VIEW IF EXISTS vw_fraud_overview_daily;

DROP TABLE IF EXISTS case_reviews;
DROP TABLE IF EXISTS fraud_alerts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id      INTEGER PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(120) UNIQUE NOT NULL,
    phone_number     VARCHAR(30),
    date_of_birth    DATE NOT NULL,
    country_code     CHAR(2) NOT NULL,
    city             VARCHAR(80) NOT NULL,
    customer_segment VARCHAR(30) NOT NULL CHECK (customer_segment IN ('Retail', 'Premier', 'Small Business', 'Student')),
    kyc_risk_rating  VARCHAR(20) NOT NULL CHECK (kyc_risk_rating IN ('Low', 'Medium', 'High')),
    onboarding_date  DATE NOT NULL,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE accounts (
    account_id      INTEGER PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES customers(customer_id),
    account_number  VARCHAR(30) UNIQUE NOT NULL,
    account_type    VARCHAR(30) NOT NULL CHECK (account_type IN ('Checking', 'Savings', 'Credit Card', 'Business Checking')),
    opened_date     DATE NOT NULL,
    account_status  VARCHAR(20) NOT NULL CHECK (account_status IN ('Open', 'Frozen', 'Closed')),
    current_balance NUMERIC(14, 2) NOT NULL DEFAULT 0,
    currency_code   CHAR(3) NOT NULL DEFAULT 'USD'
);

CREATE TABLE merchants (
    merchant_id          INTEGER PRIMARY KEY,
    merchant_name        VARCHAR(120) NOT NULL,
    merchant_category    VARCHAR(60) NOT NULL,
    country_code         CHAR(2) NOT NULL,
    city                 VARCHAR(80) NOT NULL,
    merchant_risk_rating VARCHAR(20) NOT NULL CHECK (merchant_risk_rating IN ('Low', 'Medium', 'High')),
    is_online            BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE transactions (
    transaction_id     INTEGER PRIMARY KEY,
    account_id         INTEGER NOT NULL REFERENCES accounts(account_id),
    merchant_id        INTEGER REFERENCES merchants(merchant_id),
    transaction_ts     TIMESTAMP NOT NULL,
    amount             NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    currency_code      CHAR(3) NOT NULL DEFAULT 'USD',
    transaction_type   VARCHAR(30) NOT NULL CHECK (transaction_type IN ('Purchase', 'Withdrawal', 'Transfer', 'Payment')),
    transaction_channel VARCHAR(30) NOT NULL CHECK (transaction_channel IN ('Card Present', 'Card Not Present', 'ATM', 'Online Banking', 'Mobile Banking')),
    transaction_status VARCHAR(20) NOT NULL CHECK (transaction_status IN ('Approved', 'Declined', 'Reversed')),
    country_code       CHAR(2) NOT NULL,
    city               VARCHAR(80) NOT NULL,
    device_id          VARCHAR(80),
    ip_address         INET,
    is_international   BOOLEAN NOT NULL DEFAULT FALSE,
    is_card_present    BOOLEAN NOT NULL DEFAULT TRUE,
    fraud_label        BOOLEAN,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fraud_alerts (
    alert_id          INTEGER PRIMARY KEY,
    transaction_id    INTEGER NOT NULL REFERENCES transactions(transaction_id),
    alert_created_ts  TIMESTAMP NOT NULL,
    alert_type        VARCHAR(60) NOT NULL,
    alert_severity    VARCHAR(20) NOT NULL CHECK (alert_severity IN ('Low', 'Medium', 'High', 'Critical')),
    risk_score        NUMERIC(5, 2) NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    alert_status      VARCHAR(30) NOT NULL CHECK (alert_status IN ('Open', 'In Review', 'Closed')),
    rule_description  TEXT NOT NULL
);

CREATE TABLE case_reviews (
    case_id           INTEGER PRIMARY KEY,
    alert_id          INTEGER NOT NULL REFERENCES fraud_alerts(alert_id),
    assigned_analyst  VARCHAR(80) NOT NULL,
    case_opened_ts    TIMESTAMP NOT NULL,
    case_closed_ts    TIMESTAMP,
    case_status       VARCHAR(30) NOT NULL CHECK (case_status IN ('Open', 'Pending Customer Contact', 'Closed')),
    disposition       VARCHAR(40) CHECK (disposition IN ('Confirmed Fraud', 'False Positive', 'Authorized Activity', 'Needs Follow-up')),
    analyst_notes     TEXT,
    recovery_amount   NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (recovery_amount >= 0)
);

CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_transactions_account_ts ON transactions(account_id, transaction_ts);
CREATE INDEX idx_transactions_merchant_id ON transactions(merchant_id);
CREATE INDEX idx_transactions_country_code ON transactions(country_code);
CREATE INDEX idx_transactions_fraud_label ON transactions(fraud_label);
CREATE INDEX idx_alerts_transaction_id ON fraud_alerts(transaction_id);
CREATE INDEX idx_alerts_status_severity ON fraud_alerts(alert_status, alert_severity);
CREATE INDEX idx_cases_alert_id ON case_reviews(alert_id);
