-- Synthetic sample data for the banking fraud monitoring schema.
-- Run after sql/01_schema.sql.

INSERT INTO customers (
    customer_id, first_name, last_name, email, phone_number, date_of_birth,
    country_code, city, customer_segment, kyc_risk_rating, onboarding_date, is_active
) VALUES
(1, 'Ava', 'Johnson', 'ava.johnson@example.com', '416-555-0101', '1988-04-12', 'CA', 'Toronto', 'Premier', 'Low', '2019-03-18', TRUE),
(2, 'Liam', 'Patel', 'liam.patel@example.com', '647-555-0102', '1994-11-23', 'CA', 'Mississauga', 'Retail', 'Medium', '2021-06-04', TRUE),
(3, 'Sophia', 'Chen', 'sophia.chen@example.com', '604-555-0103', '1979-01-30', 'CA', 'Vancouver', 'Small Business', 'Medium', '2018-09-12', TRUE),
(4, 'Noah', 'Williams', 'noah.williams@example.com', '212-555-0104', '1985-07-09', 'US', 'New York', 'Retail', 'Low', '2020-02-21', TRUE),
(5, 'Mia', 'Garcia', 'mia.garcia@example.com', '305-555-0105', '1999-02-18', 'US', 'Miami', 'Student', 'Low', '2022-08-29', TRUE),
(6, 'Ethan', 'Brown', 'ethan.brown@example.com', '312-555-0106', '1972-10-05', 'US', 'Chicago', 'Premier', 'High', '2017-12-14', TRUE),
(7, 'Olivia', 'Davis', 'olivia.davis@example.com', '514-555-0107', '1991-05-27', 'CA', 'Montreal', 'Retail', 'Low', '2021-01-08', TRUE),
(8, 'Lucas', 'Wilson', 'lucas.wilson@example.com', '206-555-0108', '1982-12-16', 'US', 'Seattle', 'Small Business', 'High', '2016-05-19', TRUE),
(9, 'Emma', 'Martinez', 'emma.martinez@example.com', '403-555-0109', '1996-09-03', 'CA', 'Calgary', 'Retail', 'Medium', '2023-04-02', TRUE),
(10, 'James', 'Anderson', 'james.anderson@example.com', '617-555-0110', '1968-03-22', 'US', 'Boston', 'Premier', 'Low', '2015-11-30', TRUE);

INSERT INTO accounts (
    account_id, customer_id, account_number, account_type, opened_date,
    account_status, current_balance, currency_code
) VALUES
(101, 1, 'CHK-100001', 'Checking', '2019-03-18', 'Open', 8450.25, 'CAD'),
(102, 1, 'CCD-100002', 'Credit Card', '2020-06-11', 'Open', -1240.18, 'CAD'),
(103, 2, 'CHK-100003', 'Checking', '2021-06-04', 'Open', 2300.50, 'CAD'),
(104, 3, 'BUS-100004', 'Business Checking', '2018-09-12', 'Open', 18425.70, 'CAD'),
(105, 4, 'CHK-100005', 'Checking', '2020-02-21', 'Open', 6200.00, 'USD'),
(106, 5, 'CHK-100006', 'Checking', '2022-08-29', 'Open', 760.32, 'USD'),
(107, 6, 'CCD-100007', 'Credit Card', '2017-12-14', 'Open', -6850.55, 'USD'),
(108, 7, 'SAV-100008', 'Savings', '2021-01-08', 'Open', 12150.88, 'CAD'),
(109, 8, 'BUS-100009', 'Business Checking', '2016-05-19', 'Open', 40320.19, 'USD'),
(110, 9, 'CHK-100010', 'Checking', '2023-04-02', 'Open', 1425.44, 'CAD'),
(111, 10, 'CCD-100011', 'Credit Card', '2015-11-30', 'Open', -990.31, 'USD'),
(112, 10, 'SAV-100012', 'Savings', '2016-01-15', 'Open', 25200.00, 'USD');

INSERT INTO merchants (
    merchant_id, merchant_name, merchant_category, country_code, city,
    merchant_risk_rating, is_online
) VALUES
(201, 'Maple Grocery Market', 'Grocery', 'CA', 'Toronto', 'Low', FALSE),
(202, 'Northstar Electronics', 'Electronics', 'CA', 'Vancouver', 'Medium', TRUE),
(203, 'Metro Fuel Stop', 'Fuel', 'US', 'Buffalo', 'Low', FALSE),
(204, 'Global Crypto Exchange', 'Crypto Exchange', 'MT', 'Valletta', 'High', TRUE),
(205, 'Skyline Travel', 'Travel', 'US', 'New York', 'Medium', TRUE),
(206, 'QuickCash ATM Network', 'ATM', 'US', 'Chicago', 'Medium', FALSE),
(207, 'Luxury Watch House', 'Luxury Goods', 'GB', 'London', 'High', TRUE),
(208, 'Campus Bookstore', 'Education', 'US', 'Miami', 'Low', FALSE),
(209, 'Cloud Software Pro', 'Software', 'US', 'Seattle', 'Low', TRUE),
(210, 'Harbor Restaurant Group', 'Restaurant', 'CA', 'Montreal', 'Low', FALSE),
(211, 'Offshore Betting Hub', 'Gaming', 'CW', 'Willemstad', 'High', TRUE),
(212, 'RideShare Central', 'Transportation', 'US', 'Boston', 'Low', TRUE),
(213, 'Royal Hotel Collection', 'Hospitality', 'FR', 'Paris', 'Medium', TRUE),
(214, 'Digital Gift Cards Now', 'Gift Cards', 'US', 'Dallas', 'High', TRUE),
(215, 'Downtown Pharmacy', 'Pharmacy', 'CA', 'Calgary', 'Low', FALSE);

INSERT INTO transactions (
    transaction_id, account_id, merchant_id, transaction_ts, amount, currency_code,
    transaction_type, transaction_channel, transaction_status, country_code, city,
    device_id, ip_address, is_international, is_card_present, fraud_label
) VALUES
(1001, 101, 201, '2026-01-05 09:15:00', 64.22, 'CAD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Toronto', 'dev-ava-01', '24.114.10.11', FALSE, TRUE, FALSE),
(1002, 101, 210, '2026-01-06 19:42:00', 88.10, 'CAD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Montreal', 'dev-ava-01', '24.114.10.11', FALSE, TRUE, FALSE),
(1003, 102, 202, '2026-01-10 13:26:00', 420.55, 'CAD', 'Purchase', 'Card Not Present', 'Approved', 'CA', 'Vancouver', 'dev-ava-02', '70.48.12.91', FALSE, FALSE, FALSE),
(1004, 102, 207, '2026-01-11 02:14:00', 4890.00, 'GBP', 'Purchase', 'Card Not Present', 'Approved', 'GB', 'London', 'unknown-device-77', '185.220.101.14', TRUE, FALSE, TRUE),
(1005, 102, 214, '2026-01-11 02:21:00', 950.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'Dallas', 'unknown-device-77', '185.220.101.14', TRUE, FALSE, TRUE),
(1006, 103, 201, '2026-01-08 08:35:00', 35.75, 'CAD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Toronto', 'dev-liam-01', '99.230.10.45', FALSE, TRUE, FALSE),
(1007, 103, 203, '2026-01-09 07:58:00', 52.15, 'USD', 'Purchase', 'Card Present', 'Approved', 'US', 'Buffalo', 'dev-liam-01', '99.230.10.45', TRUE, TRUE, FALSE),
(1008, 103, 204, '2026-01-09 23:47:00', 2200.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'MT', 'Valletta', 'unknown-device-12', '45.83.64.9', TRUE, FALSE, TRUE),
(1009, 103, 211, '2026-01-10 00:03:00', 1800.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'CW', 'Willemstad', 'unknown-device-12', '45.83.64.9', TRUE, FALSE, TRUE),
(1010, 104, 209, '2026-01-03 10:05:00', 350.00, 'USD', 'Payment', 'Online Banking', 'Approved', 'US', 'Seattle', 'dev-sophia-01', '142.112.88.10', TRUE, FALSE, FALSE),
(1011, 104, 209, '2026-01-04 10:05:00', 350.00, 'USD', 'Payment', 'Online Banking', 'Approved', 'US', 'Seattle', 'dev-sophia-01', '142.112.88.10', TRUE, FALSE, FALSE),
(1012, 104, 214, '2026-01-07 21:30:00', 2500.00, 'USD', 'Purchase', 'Card Not Present', 'Declined', 'US', 'Dallas', 'unknown-device-98', '103.21.244.7', TRUE, FALSE, TRUE),
(1013, 105, 212, '2026-01-05 08:12:00', 23.55, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'Boston', 'dev-noah-01', '73.200.14.66', FALSE, FALSE, FALSE),
(1014, 105, 205, '2026-01-05 15:40:00', 740.80, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'New York', 'dev-noah-01', '73.200.14.66', FALSE, FALSE, FALSE),
(1015, 105, 206, '2026-01-06 03:12:00', 900.00, 'USD', 'Withdrawal', 'ATM', 'Approved', 'US', 'Chicago', 'unknown-atm-card', '198.51.100.22', FALSE, TRUE, TRUE),
(1016, 106, 208, '2026-01-07 12:45:00', 78.44, 'USD', 'Purchase', 'Card Present', 'Approved', 'US', 'Miami', 'dev-mia-01', '172.58.19.33', FALSE, TRUE, FALSE),
(1017, 106, 214, '2026-01-07 23:52:00', 499.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'Dallas', 'dev-mia-02', '172.58.19.33', FALSE, FALSE, FALSE),
(1018, 106, 214, '2026-01-08 00:06:00', 499.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'Dallas', 'dev-mia-02', '172.58.19.33', FALSE, FALSE, TRUE),
(1019, 107, 201, '2026-01-02 17:10:00', 110.40, 'USD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Toronto', 'dev-ethan-01', '68.54.101.3', TRUE, TRUE, FALSE),
(1020, 107, 204, '2026-01-02 17:42:00', 3400.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'MT', 'Valletta', 'dev-ethan-01', '68.54.101.3', TRUE, FALSE, TRUE),
(1021, 107, 204, '2026-01-02 17:48:00', 3100.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'MT', 'Valletta', 'dev-ethan-01', '68.54.101.3', TRUE, FALSE, TRUE),
(1022, 108, 210, '2026-01-05 20:05:00', 66.90, 'CAD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Montreal', 'dev-olivia-01', '70.30.88.2', FALSE, TRUE, FALSE),
(1023, 108, 202, '2026-01-06 14:20:00', 899.99, 'CAD', 'Purchase', 'Card Not Present', 'Approved', 'CA', 'Vancouver', 'dev-olivia-01', '70.30.88.2', FALSE, FALSE, FALSE),
(1024, 108, 213, '2026-01-06 14:37:00', 2800.00, 'EUR', 'Purchase', 'Card Not Present', 'Approved', 'FR', 'Paris', 'new-device-fr', '193.56.29.8', TRUE, FALSE, TRUE),
(1025, 109, 209, '2026-01-03 09:30:00', 1200.00, 'USD', 'Payment', 'Online Banking', 'Approved', 'US', 'Seattle', 'dev-lucas-01', '76.121.33.45', FALSE, FALSE, FALSE),
(1026, 109, 209, '2026-01-10 09:30:00', 1200.00, 'USD', 'Payment', 'Online Banking', 'Approved', 'US', 'Seattle', 'dev-lucas-01', '76.121.33.45', FALSE, FALSE, FALSE),
(1027, 109, 211, '2026-01-12 01:17:00', 7600.00, 'USD', 'Transfer', 'Online Banking', 'Approved', 'CW', 'Willemstad', 'unknown-device-11', '198.98.51.42', TRUE, FALSE, TRUE),
(1028, 110, 215, '2026-01-09 16:55:00', 24.99, 'CAD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Calgary', 'dev-emma-01', '99.245.88.12', FALSE, TRUE, FALSE),
(1029, 110, 201, '2026-01-10 11:13:00', 97.33, 'CAD', 'Purchase', 'Card Present', 'Approved', 'CA', 'Toronto', 'dev-emma-01', '99.245.88.12', FALSE, TRUE, FALSE),
(1030, 110, 206, '2026-01-10 23:58:00', 700.00, 'CAD', 'Withdrawal', 'ATM', 'Approved', 'CA', 'Calgary', 'unknown-atm-card', '99.245.88.12', FALSE, TRUE, TRUE),
(1031, 111, 212, '2026-01-03 18:20:00', 18.40, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'Boston', 'dev-james-01', '98.216.77.10', FALSE, FALSE, FALSE),
(1032, 111, 205, '2026-01-05 09:05:00', 1120.00, 'USD', 'Purchase', 'Card Not Present', 'Approved', 'US', 'New York', 'dev-james-01', '98.216.77.10', FALSE, FALSE, FALSE),
(1033, 111, 207, '2026-01-05 09:11:00', 6500.00, 'GBP', 'Purchase', 'Card Not Present', 'Approved', 'GB', 'London', 'new-device-uk', '185.220.101.45', TRUE, FALSE, TRUE),
(1034, 112, NULL, '2026-01-06 13:00:00', 5000.00, 'USD', 'Transfer', 'Online Banking', 'Approved', 'US', 'Boston', 'dev-james-02', '98.216.77.11', FALSE, FALSE, FALSE),
(1035, 112, NULL, '2026-01-06 13:05:00', 5000.00, 'USD', 'Transfer', 'Online Banking', 'Approved', 'US', 'Boston', 'dev-james-02', '98.216.77.11', FALSE, FALSE, FALSE);

INSERT INTO fraud_alerts (
    alert_id, transaction_id, alert_created_ts, alert_type, alert_severity,
    risk_score, alert_status, rule_description
) VALUES
(5001, 1004, '2026-01-11 02:15:00', 'High Value International Card-Not-Present', 'Critical', 96.50, 'Closed', 'Large night-time purchase from a new device in a high-risk merchant category.'),
(5002, 1005, '2026-01-11 02:22:00', 'Velocity and Gift Card Risk', 'High', 88.00, 'Closed', 'Multiple card-not-present transactions from the same unknown device within 10 minutes.'),
(5003, 1008, '2026-01-09 23:48:00', 'High-Risk Merchant Category', 'High', 91.25, 'In Review', 'Crypto exchange transaction from new device and international IP.'),
(5004, 1009, '2026-01-10 00:04:00', 'Cross-Border Velocity', 'Critical', 97.00, 'In Review', 'Second high-risk international transaction within 20 minutes.'),
(5005, 1012, '2026-01-07 21:31:00', 'Declined Gift Card Attempt', 'Medium', 74.00, 'Open', 'Declined high-value gift card purchase from unknown device.'),
(5006, 1015, '2026-01-06 03:13:00', 'Unusual ATM Withdrawal', 'High', 85.50, 'Closed', 'Large ATM withdrawal at unusual hour and unusual city.'),
(5007, 1018, '2026-01-08 00:07:00', 'Duplicate Gift Card Purchase', 'Medium', 78.25, 'Closed', 'Repeated same merchant and amount within 15 minutes.'),
(5008, 1020, '2026-01-02 17:43:00', 'High-Risk Crypto Merchant', 'High', 89.00, 'Closed', 'High-value crypto transaction by high KYC-risk customer.'),
(5009, 1021, '2026-01-02 17:49:00', 'Rapid Repeat Crypto Purchase', 'Critical', 98.75, 'Closed', 'Repeat high-value transaction at same high-risk merchant within 10 minutes.'),
(5010, 1024, '2026-01-06 14:38:00', 'New Country and Device', 'High', 87.00, 'In Review', 'International purchase from new device shortly after domestic transaction.'),
(5011, 1027, '2026-01-12 01:18:00', 'High-Value Offshore Transfer', 'Critical', 99.00, 'Open', 'Large transfer to high-risk offshore gaming merchant.'),
(5012, 1030, '2026-01-10 23:59:00', 'Unusual ATM Withdrawal', 'Medium', 76.50, 'Open', 'ATM withdrawal above customer normal amount near midnight.'),
(5013, 1033, '2026-01-05 09:12:00', 'Luxury Goods International Purchase', 'Critical', 95.75, 'Closed', 'Large luxury goods purchase from new device and foreign country.');

INSERT INTO case_reviews (
    case_id, alert_id, assigned_analyst, case_opened_ts, case_closed_ts,
    case_status, disposition, analyst_notes, recovery_amount
) VALUES
(7001, 5001, 'N. Ahmed', '2026-01-11 08:30:00', '2026-01-11 15:45:00', 'Closed', 'Confirmed Fraud', 'Customer confirmed card was not in possession at time of purchase.', 3725.00),
(7002, 5002, 'N. Ahmed', '2026-01-11 08:35:00', '2026-01-11 15:50:00', 'Closed', 'Confirmed Fraud', 'Linked to same compromised device as prior transaction.', 950.00),
(7003, 5003, 'R. Singh', '2026-01-10 09:00:00', NULL, 'Pending Customer Contact', 'Needs Follow-up', 'Customer contact attempt pending.', 0.00),
(7004, 5004, 'R. Singh', '2026-01-10 09:05:00', NULL, 'Pending Customer Contact', 'Needs Follow-up', 'Related to previous crypto alert.', 0.00),
(7005, 5006, 'M. Clarke', '2026-01-06 09:20:00', '2026-01-06 13:15:00', 'Closed', 'False Positive', 'Customer confirmed travel and ATM withdrawal.', 0.00),
(7006, 5007, 'S. Wong', '2026-01-08 09:10:00', '2026-01-08 11:42:00', 'Closed', 'Authorized Activity', 'Customer purchased gift cards for family.', 0.00),
(7007, 5008, 'T. Brooks', '2026-01-02 18:10:00', '2026-01-03 10:30:00', 'Closed', 'Confirmed Fraud', 'Account takeover indicators found.', 3400.00),
(7008, 5009, 'T. Brooks', '2026-01-02 18:15:00', '2026-01-03 10:35:00', 'Closed', 'Confirmed Fraud', 'Second unauthorized crypto transaction.', 3100.00),
(7009, 5010, 'A. Morgan', '2026-01-06 15:15:00', NULL, 'Pending Customer Contact', 'Needs Follow-up', 'Customer contact not completed.', 0.00),
(7010, 5013, 'P. Rivera', '2026-01-05 09:45:00', '2026-01-05 14:25:00', 'Closed', 'Confirmed Fraud', 'Customer confirmed no travel or online purchase.', 6500.00);
