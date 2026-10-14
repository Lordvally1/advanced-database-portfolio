CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Wallets (
    wallet_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INT NOT NULL REFERENCES Customers(customer_id) ON DELETE CASCADE,
    account_number VARCHAR(10) UNIQUE NOT NULL,
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0.00),
    currency VARCHAR(3) DEFAULT 'NGN',
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_wallet_id INT NOT NULL REFERENCES Wallets(wallet_id),
    receiver_wallet_id INT NOT NULL REFERENCES Wallets(wallet_id),
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0.00),
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('TRANSFER', 'DEPOSIT', 'WITHDRAWAL')),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_different_wallets CHECK (sender_wallet_id <> receiver_wallet_id)
);

CREATE TABLE AuditLogs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id INT REFERENCES Transactions(transaction_id) ON DELETE SET NULL,
    action_performed VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);