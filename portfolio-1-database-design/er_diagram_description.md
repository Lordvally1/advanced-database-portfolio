# ER Diagram Description

## Core entities

### Customers
- customer_id (PK)
- full_name
- email
- phone_number
- created_at

### Wallets
- wallet_id (PK)
- customer_id (FK -> Customers.customer_id)
- account_number
- balance
- currency
- status
- created_at

### Transactions
- transaction_id (PK)
- sender_wallet_id (FK -> Wallets.wallet_id)
- receiver_wallet_id (FK -> Wallets.wallet_id)
- amount
- transaction_type
- status
- created_at

### AuditLogs
- log_id (PK)
- transaction_id (FK -> Transactions.transaction_id, nullable)
- action_performed
- ip_address
- logged_at

## Relationship summary
- One customer can own many wallets.
- One wallet belongs to one customer.
- One wallet can send many transactions and receive many transactions.
- Each transaction may generate one or more audit log entries.

## Design notes
- The schema follows 3NF for the wallet and customer data model.
- The `Transactions` table prevents self-transfer via a CHECK constraint.
- Wallet balances are validated to avoid negative values.
- Audit events are retained for traceability and financial compliance.
