-- Concurrency simulation for wallet transfer safety
-- This script demonstrates row locking and transactional consistency.

BEGIN;

SELECT balance
FROM Wallets
WHERE wallet_id = 1
FOR UPDATE;

SELECT balance
FROM Wallets
WHERE wallet_id = 2
FOR UPDATE;

-- Simulated debit and credit logic
UPDATE Wallets
SET balance = balance - 250.00
WHERE wallet_id = 1;

UPDATE Wallets
SET balance = balance + 250.00
WHERE wallet_id = 2;

INSERT INTO Transactions (
    sender_wallet_id,
    receiver_wallet_id,
    amount,
    transaction_type,
    status
)
VALUES (
    1,
    2,
    250.00,
    'TRANSFER',
    'SUCCESS'
);

COMMIT;

-- Notes:
-- - Locks ensure that concurrent transfers cannot produce a lost update.
-- - This pattern is appropriate for financial transactions where ledger integrity is critical.
