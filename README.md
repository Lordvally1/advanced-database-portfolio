PayPulse — Advanced Database Systems Portfolio (MIT8103)
Student Name: [Obiora Valentine Ezekaka]
Matriculation Number: [301809869]
Degree Program: Master of Information Technology (MIT)   
Academic Session: 2026/2027 Academic Session   
Course Code: MIT8103 — Advanced Database Systems   
1. Case Study OverviewPayPulse is a digital wallet and peer-to-peer (P2P) financial platform designed for high-throughput transactional operations. The system supports core functions including user onboarding (KYC), wallet creation, fund deposits, atomic wallet-to-wallet transfers, withdrawals, and real-time transaction logging.   Target Users: Customers, System Administrators, Compliance Officers, External Payment Gateways.   Core Requirements: Absolute transactional integrity (ACID guarantees) for ledger balances, sub-second activity updates for mobile users, and distributed high availability.   
2. Portfolio Project StructurePlaintextadvanced-database-portfolio/
│
├── portfolio-1-database-design/
│   ├── schema.sql
│   └── er_diagram_description.md
│
├── portfolio-2-query-optimisation/
│   ├── unoptimised_query.sql
│   ├── optimisation.sql
│   └── performance_analysis.md
│
├── portfolio-3-transactions-concurrency/
│   ├── atomic_transfer.sql
│   └── concurrency_simulation.sql
│
├── portfolio-4-nosql/
│   ├── customer_feed_model.json
│   └── nosql_implementation.py
│
├── portfolio-5-distributed-cloud/
│   └── architecture.md
│
└── README.md
3. Summary of Portfolio ModulesPortfolio 1: Database Design & ModellingRelational Schema: Designed 4 primary tables (Customers, Wallets, Transactions, AuditLogs).   Constraints: Enforced Primary Keys, Foreign Keys with cascading/nullifying rules, CHECK conditions on non-negative balances (balance >= 0), and self-transfer prevention (sender_wallet_id <> receiver_wallet_id).   Normalisation: Evaluated functional dependencies to achieve Third Normal Form (3NF), eliminating transitive dependencies between customers and their wallet transactions.   Portfolio 2: Query Processing & OptimisationBenchmark Task: Aggregating total successful outgoing spending per customer for financial compliance auditing.   Baseline Analysis: Executed EXPLAIN ANALYZE on a unindexed dataset, revealing an expensive sequential table scan (Execution time: 124.31 ms, Cost: 18,450 units).   Optimisation: Applied composite indexing (idx_transactions_perf on sender_wallet_id, status, created_at with INCLUDE (amount)), reducing execution time to 4.12 ms (a 96.7% improvement).   Portfolio 3: Transactions & Concurrency ControlACID Guarantees: Constructed an atomic funds transfer script utilizing READ COMMITTED isolation level.   Concurrency Control: Utilized explicit pessimistic row-level locking (SELECT ... FOR UPDATE) to prevent race conditions (Lost Updates) when multiple concurrent transactions attempt to debit the same account simultaneously.   Portfolio 4: NoSQL and Advanced Data ModelsDocument Store Model: Re-engineered the real-time customer feed module in MongoDB to circumvent relational join overheads.   Implementation: Developed a Python (pymongo) script using atomic $push operators to maintain a fixed-length array of recent transactions directly inside the customer document.   Portfolio 5: Distributed and Cloud Database StrategyCAP Theorem Position: Configured a CP (Consistency + Partition Tolerance) system using CockroachDB / Distributed PostgreSQL.   Sharding & Replication: Applied horizontal hash partitioning on customer_id paired with multi-region Raft Consensus Protocol replication (Replication Factor = 3) to prevent split-brain monetary duplication.   Cloud Architecture: Configured Multi-AZ deployment on AWS Aurora PostgreSQL with automated failover and read-replicas for analytics.   
4. How to Run and TestPrerequisitesPostgreSQL 14+MongoDB 6.0+Python 3.9+ with pymongoExecution StepsDatabase Initialization:Bashpsql -U postgres -d paypulse -f portfolio-1-database-design/schema.sql
Run Query Optimisation Tests:Bashpsql -U postgres -d paypulse -f portfolio-2-query-optimisation/optimisation.sql
Execute Transaction Lock Simulation:Bashpsql -U postgres -d paypulse -f portfolio-3-transactions-concurrency/atomic_transfer.sql
Execute NoSQL Pipeline:Bashpython portfolio-4-nosql/nosql_implementation.py
5. Individual Technical ReflectionDeveloping this database portfolio provided practical insights into balancing relational data consistency with NoSQL performance. Index tuning demonstrated how query execution engines process logical trees into physical disk block reads, while concurrency simulations underlined the importance of explicit row locking in transaction processing.  