-- Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    balance DECIMAL(12, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(10), -- 'credit' or 'debit'
    amount DECIMAL(10, 2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Total balance per customer
SELECT c.customer_name, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_name;

-- Total credit and debit per account
SELECT account_id,
       SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END) AS total_credits,
       SUM(CASE WHEN transaction_type = 'debit' THEN amount ELSE 0 END) AS total_debits
FROM transactions
GROUP BY account_id;

-- Accounts with balance less than ₹5,000
SELECT account_id, balance
FROM accounts
WHERE balance < 5000;

-- Transactions in the last 30 days
SELECT *
FROM transactions
WHERE transaction_date >= CURRENT_DATE - INTERVAL '30 days';

-- INNER JOIN: Customer with their account transactions
SELECT c.customer_name, a.account_type, t.transaction_type, t.amount
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id;

-- LEFT JOIN: Customers who never made a transaction
SELECT c.customer_name, t.transaction_id
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;
