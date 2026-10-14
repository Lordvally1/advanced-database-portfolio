# Performance Analysis

## Query objective
The compliance dashboard needs to calculate the total successful outgoing spend per customer.

## Baseline behaviour
The original query was executed against a dataset without the supporting index strategy. The database engine performed a full scan of the transactions table, leading to poor performance and higher I/O cost.

## Benchmark summary
- Baseline execution time: 124.31 ms
- Baseline cost estimate: 18,450 units
- Optimised execution time: 4.12 ms
- Improvement: 96.7%

## Optimisation strategy
A composite index was applied to the transaction table:

```sql
CREATE INDEX idx_transactions_perf
ON Transactions (sender_wallet_id, status, created_at)
INCLUDE (amount);
```

## Result
The query planner can now use the index to narrow the relevant rows before aggregation, reducing both CPU and disk access.

## Recommendation
Maintain the composite index for all high-frequency approval, audit, and compliance queries involving wallet-to-wallet transfers.
