-- 7.1 3NF Tables
CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    account_no VARCHAR(20) UNIQUE,
    branch_id INT,
    account_type VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_type VARCHAR(20), -- 'credit' or 'debit'
    amount DECIMAL(10,2),
    transaction_date DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 7.2 Indexing
CREATE INDEX idx_account_no ON accounts(account_no);
CREATE INDEX idx_transaction_date ON transactions(transaction_date);
CREATE INDEX idx_branch_id ON accounts(branch_id);

-- 7.3 EXPLAIN for balance checks
EXPLAIN
SELECT SUM(
  CASE WHEN transaction_type = 'credit' THEN amount
       WHEN transaction_type = 'debit' THEN -amount
  END
) AS balance
FROM transactions
WHERE account_id = 101;

-- 7.4 Subquery: Running balance
SELECT t.transaction_id, t.transaction_date, t.amount, t.transaction_type,
  (SELECT SUM(
     CASE WHEN transaction_type = 'credit' THEN amount
          WHEN transaction_type = 'debit' THEN -amount
     END)
   FROM transactions t2
   WHERE t2.account_id = t.account_id AND t2.transaction_date <= t.transaction_date
  ) AS running_balance
FROM transactions t
WHERE t.account_id = 101
ORDER BY t.transaction_date;

-- 7.5 Denormalized statement view
CREATE VIEW account_statement_view AS
SELECT 
  c.name AS customer_name,
  a.account_no,
  b.name AS branch_name,
  t.transaction_date,
  t.transaction_type,
  t.amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches b ON a.branch_id = b.branch_id;

-- 7.6 LIMIT: Latest 10 transactions for an account
SELECT * 
FROM transactions
WHERE account_id = 101
ORDER BY transaction_date DESC
LIMIT 10;
