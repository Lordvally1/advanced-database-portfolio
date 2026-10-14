-- Create composite index to optimize join and filter performance
CREATE INDEX idx_transactions_perf
ON Transactions (sender_wallet_id, status, created_at)
INCLUDE (amount);

CREATE INDEX idx_wallets_cust_status
ON Wallets (customer_id, status);

-- Optimized compliance query for total successful outgoing spend per customer
EXPLAIN ANALYZE
SELECT
    c.customer_id,
    c.full_name,
    SUM(t.amount) AS total_spent,
    COUNT(t.transaction_id) AS total_successful_transfers
FROM Transactions t
JOIN Wallets w ON t.sender_wallet_id = w.wallet_id
JOIN Customers c ON c.customer_id = w.customer_id
WHERE t.status = 'SUCCESS'
  AND t.transaction_type = 'TRANSFER'
  AND t.created_at >= '2026-01-01 00:00:00'
GROUP BY c.customer_id, c.full_name
HAVING SUM(t.amount) > 1000.00
ORDER BY total_spent DESC;

-- Additional operational query for wallet activity review
SELECT
    c.full_name,
    w.account_number,
    w.balance,
    COUNT(t.transaction_id) AS total_activity
FROM Customers c
JOIN Wallets w ON w.customer_id = c.customer_id
LEFT JOIN Transactions t
    ON t.sender_wallet_id = w.wallet_id
   OR t.receiver_wallet_id = w.wallet_id
WHERE w.status = 'ACTIVE'
GROUP BY c.full_name, w.account_number, w.balance
ORDER BY w.balance DESC;