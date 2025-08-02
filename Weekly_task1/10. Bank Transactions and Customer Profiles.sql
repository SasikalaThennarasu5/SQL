-- 1. Create tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    balance DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(10,2),
    transaction_date DATE,
    type VARCHAR(10),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 2. IS NULL - Accounts with no transactions
SELECT a.account_id, c.name
FROM accounts a
INNER JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;

-- 3. INNER JOIN - Combine customer and account info
SELECT c.customer_id, c.name, a.account_id, a.account_type, a.balance
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id;

-- 4. SUM() - Total deposits per customer
SELECT c.customer_id, c.name, SUM(t.amount) AS total_deposit
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
WHERE t.type = 'deposit'
GROUP BY c.customer_id, c.name;

-- 5. CASE - Risk-level classification
SELECT c.customer_id, c.name, a.balance,
  CASE
    WHEN a.balance > 100000 THEN 'High Risk'
    WHEN a.balance BETWEEN 50000 AND 100000 THEN 'Moderate Risk'
    ELSE 'Low Risk'
  END AS risk_level
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id;

-- 6. Subquery in FROM - Daily balance change
SELECT daily.customer_id, daily.transaction_date, SUM(daily.change_amount) AS total_change
FROM (
    SELECT c.customer_id, t.transaction_date,
           CASE WHEN t.type = 'deposit' THEN t.amount
                WHEN t.type = 'withdrawal' THEN -t.amount
                ELSE 0 END AS change_amount
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    JOIN transactions t ON a.account_id = t.account_id
) AS daily
GROUP BY daily.customer_id, daily.transaction_date;

-- 7. UNION ALL - Combine savings and current account statements
SELECT a.account_id, t.transaction_id, t.amount, t.transaction_date, 'Savings' AS source
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE a.account_type = 'savings'
UNION ALL
SELECT a.account_id, t.transaction_id, t.amount, t.transaction_date, 'Current' AS source
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE a.account_type = 'current';
