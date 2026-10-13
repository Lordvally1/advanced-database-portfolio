-- Create composite index to optimize join and filter performance
CREATE INDEX idx_transactions_perf 
ON Transactions (sender_wallet_id, status, created_at) 
INCLUDE (amount);

CREATE INDEX idx_wallets_cust_status 
ON Wallets (customer_id, status);

-- Optimized Query with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT 
    w.account_number, 
    c.full_name, 
    SUM(t.amount) AS total_spent,
    COUNT(t.transaction_id) AS total_transactions
FROM Transactions t
INNER JOIN Wallets w ON t.sender_wallet_id = w.wallet_id
INNER JOIN Customers c ON w.customer_id = c.customer_id
WHERE t.status = 'SUCCESS' 
  AND w.status = 'ACTIVE'
  AND t.created_at >= '2026-01-01 00:00:00'
GROUP BY w.account_number, c.full_name
HAVING SUM(t.amount) > 1000.00;
