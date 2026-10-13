# Distributed & Cloud Database Strategy: PayPulse

## 1. CAP Theorem & Consistency Model
PayPulse adopts a CP (Consistency + Partition Tolerance) architecture using CockroachDB/Distributed PostgreSQL. Financial balances require strict serializability to prevent double-spending anomalies across multi-region nodes.

## 2. Sharding & Replication Strategy
- **Sharding Key:** Hash partitioning on `customer_id`.
- **Replication Protocol:** Multi-Region Raft Consensus Protocol with a replication factor of 3.
- **Cloud Infrastructure:** Multi-AZ AWS Aurora PostgreSQL deployment with automatic failover and read-replicas for analytical queries.
