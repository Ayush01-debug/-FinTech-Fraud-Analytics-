create database fintech;
use fintech;

CREATE TABLE fintech_transactions_clean(
    transaction_id INT PRIMARY KEY,
    amount DECIMAL(10,2),
    transaction_hour INT CHECK (transaction_hour BETWEEN 0 AND 23),
    merchant_category VARCHAR(50),
    foreign_transaction INT CHECK (foreign_transaction IN (0,1)),
    location_mismatch INT CHECK (location_mismatch IN (0,1)),
    device_trust_score INT CHECK (device_trust_score BETWEEN 0 AND 100),
    velocity_last_24h INT,
    cardholder_age INT,
    is_fraud INT CHECK (is_fraud IN (0,1))
);
select * from fintech_transactions_clean;

#Fraud Rate by Merchant Category
#This helps identify high-risk merchant categories.
SELECT
    merchant_category,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fintech_transactions_clean
GROUP BY merchant_category
ORDER BY fraud_rate_pct DESC;

#Foreign vs Domestic Fraud Impact
SELECT
    CASE
        WHEN foreign_transaction = 1 THEN 'Foreign'
        ELSE 'Domestic'
    END AS transaction_type
FROM fintech_transactions_clean;

#Location Mismatch Risk Analysis
SELECT 
    location_mismatch,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate
    FROM fintech_transactions_clean
GROUP BY location_mismatch;

#Device Trust Score vs Fraud
SELECT
    CASE
        WHEN device_trust_score < 40 THEN 'Low Trust'
        WHEN device_trust_score BETWEEN 40 AND 70 THEN 'Medium Trust'
        ELSE 'High Trust'
    END AS device_trust_level,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM fintech_transactions_clean
GROUP BY device_trust_level
ORDER BY fraud_rate DESC;

#TRANSACTION VELOCITY VS FRAUD	
SELECT
    CASE
        WHEN velocity_last_24h <= 3 THEN 'Low Velocity'
        WHEN velocity_last_24h BETWEEN 4 AND 10 THEN 'Medium Velocity'
        ELSE 'High Velocity'
    END AS velocity_band,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM fintech_transactions_clean
GROUP BY velocity_band
ORDER BY fraud_rate DESC;

#High-Value Fraud Loss Concentration
SELECT
    CASE
        WHEN amount < 100 THEN 'Low Amount'
        WHEN amount BETWEEN 100 AND 500 THEN 'Medium Amount'
        ELSE 'High Amount'
    END AS amount_band,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    SUM(
        CASE 
            WHEN is_fraud = 1 THEN amount 
            ELSE 0 
        END
    ) AS fraud_loss
FROM fintech_transactions_clean
GROUP BY amount_band
ORDER BY fraud_loss DESC;

#Time-Based Fraud Pattern
SELECT
    transaction_hour,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn
FROM fintech_transactions_clean
GROUP BY transaction_hour
ORDER BY fraud_txn DESC;

SELECT * FROM fintech_transactions_clean;
