-- Baseline query for compliance reporting
-- This query scans the transactions table without a covering index.

SELECT
    w.customer_id,
    SUM(t.amount) AS total_spending
FROM Transactions t
JOIN Wallets w ON w.wallet_id = t.sender_wallet_id
WHERE t.status = 'SUCCESS'
  AND t.transaction_type = 'TRANSFER'
GROUP BY w.customer_id
ORDER BY total_spending DESC;

-- Notes:
-- - This pattern is useful for demonstrating the need for performance tuning.
-- - On a large dataset, the lack of an index on sender_wallet_id, status, and created_at
--   will produce a high-cost sequential scan.
