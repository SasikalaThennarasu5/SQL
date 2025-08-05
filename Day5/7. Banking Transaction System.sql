-- 1. Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(10, 2) NOT NULL CHECK (balance >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(10, 2),
    type VARCHAR(10), -- 'credit' or 'debit'
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 2. Insert Data
INSERT INTO customers VALUES (1, 'Alice', 'alice@mail.com'), (2, 'Bob', 'bob@mail.com');

INSERT INTO accounts VALUES (1001, 1, 5000.00), (1002, 2, 3000.00);

-- 3. Update balance after a deposit
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 1001;

-- 4. Delete closed account
DELETE FROM accounts WHERE account_id = 1002;

-- 5. Drop FOREIGN KEY constraint if needed
ALTER TABLE accounts DROP FOREIGN KEY accounts_ibfk_1;

-- 6. Transaction: Transfer from A to B
START TRANSACTION;

-- Debit from Alice
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1001;

-- Credit to Bob
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 1002;

-- Rollback if any error
-- For demonstration, assume condition check
SELECT balance INTO @bal FROM accounts WHERE account_id = 1001;
IF @bal < 0 THEN
    ROLLBACK;
ELSE
    COMMIT;
END IF;

-- 7. Simulate Isolation (pseudo-code for concurrency testing)
-- Session 1:
START TRANSACTION;
UPDATE accounts SET balance = balance - 500 WHERE account_id = 1001;

-- Session 2 (runs before Session 1 commits):
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1001; -- Might show old or locked data depending on isolation level

-- Back to Session 1:
COMMIT;

-- Session 2 continues:
-- SELECT balance now shows updated value if isolation level allows
