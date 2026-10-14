-- PayPulse sample data
INSERT INTO Customers (full_name, email, phone_number) VALUES
    ('Ada Okafor', 'ada.okafor@paypulse.com', '+2348000000001'),
    ('Chinedu Adebayo', 'chinedu.adebayo@paypulse.com', '+2348000000002'),
    ('Grace Nwosu', 'grace.nwosu@paypulse.com', '+2348000000003'),
    ('Daniel Idowu', 'daniel.idowu@paypulse.com', '+2348000000004');

INSERT INTO Wallets (customer_id, account_number, balance, currency, status) VALUES
    (1, '0012345678', 25000.00, 'NGN', 'ACTIVE'),
    (2, '0012345679', 18000.00, 'NGN', 'ACTIVE'),
    (3, '0012345680', 7600.00, 'NGN', 'ACTIVE'),
    (4, '0012345681', 35000.00, 'NGN', 'FROZEN');

INSERT INTO Transactions (sender_wallet_id, receiver_wallet_id, amount, transaction_type, status) VALUES
    (1, 2, 5000.00, 'TRANSFER', 'SUCCESS'),
    (2, 1, 2500.00, 'TRANSFER', 'SUCCESS'),
    (3, 1, 1200.00, 'DEPOSIT', 'SUCCESS'),
    (1, 3, 800.00, 'TRANSFER', 'FAILED'),
    (2, 3, 3000.00, 'TRANSFER', 'SUCCESS');

INSERT INTO AuditLogs (transaction_id, action_performed, ip_address) VALUES
    (1, 'Transfer initiated and approved', '192.168.1.10'),
    (2, 'Funds credited to customer wallet', '192.168.1.14'),
    (3, 'Cash-in posted by gateway', '10.0.0.5'),
    (5, 'Compliance verification approved', '172.16.0.3');

SELECT c.customer_id, c.full_name, w.wallet_id, w.balance
FROM Customers c
JOIN Wallets w ON w.customer_id = c.customer_id
ORDER BY c.customer_id;

SELECT w.customer_id, SUM(t.amount) AS total_successful_outflow
FROM Transactions t
JOIN Wallets w ON w.wallet_id = t.sender_wallet_id
WHERE t.status = 'SUCCESS'
GROUP BY w.customer_id
ORDER BY total_successful_outflow DESC;
