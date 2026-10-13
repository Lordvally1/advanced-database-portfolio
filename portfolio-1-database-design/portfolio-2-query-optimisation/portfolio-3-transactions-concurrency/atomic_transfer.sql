BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Lock sender row to prevent concurrent lost update anomalies
SELECT balance FROM Wallets WHERE wallet_id = 1 FOR UPDATE;

UPDATE Wallets 
SET balance = balance - 250.00 
WHERE wallet_id = 1 AND balance >= 250.00;

UPDATE Wallets 
SET balance = balance + 250.00 
WHERE wallet_id = 2;

INSERT INTO Transactions (sender_wallet_id, receiver_wallet_id, amount, transaction_type, status)
VALUES (1, 2, 250.00, 'TRANSFER', 'SUCCESS');

COMMIT;
