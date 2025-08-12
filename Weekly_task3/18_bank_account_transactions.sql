-- Task 18: Bank Account Transactions

CREATE TABLE accounts (
    id INT PRIMARY KEY,
    user_id INT,
    balance DECIMAL(10,2)
);

CREATE TABLE transactions (
    id INT PRIMARY KEY,
    account_id INT,
    type VARCHAR(10),
    amount DECIMAL(10,2),
    timestamp DATETIME
);

-- Sample Data
INSERT INTO accounts VALUES (1, 1, 1000.00);
INSERT INTO transactions VALUES (1, 1, 'credit', 200.00, '2025-07-10 10:00:00');

-- Calculate balance
WITH txn_sum AS (
    SELECT account_id,
           SUM(CASE WHEN type='credit' THEN amount ELSE -amount END) AS net
    FROM transactions
    GROUP BY account_id
)
SELECT a.id, a.balance + t.net AS updated_balance
FROM accounts a
JOIN txn_sum t ON a.id = t.account_id;