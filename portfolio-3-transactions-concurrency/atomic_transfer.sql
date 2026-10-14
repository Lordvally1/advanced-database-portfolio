BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Lock both wallet rows before updating balances to avoid race conditions
SELECT wallet_id, balance
FROM Wallets
WHERE wallet_id IN (1, 2)
ORDER BY wallet_id
FOR UPDATE;

-- Validate available funds before debiting the sender
UPDATE Wallets
SET balance = balance - 250.00
WHERE wallet_id = 1
  AND balance >= 250.00;

-- Ensure the debit succeeded before crediting the recipient
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

INSERT INTO AuditLogs (
    transaction_id,
    action_performed,
    ip_address
)
VALUES (
    currval('transactions_transaction_id_seq'),
    'Wallet-to-wallet transfer completed',
    '10.0.0.21'
);

COMMIT;

-- If the sender wallet does not have enough funds, the transaction should fail and roll back.
-- This ensures the ledger remains consistent and no negative balances are created.