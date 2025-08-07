-- STEP 1: OLTP TABLES
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender VARCHAR(10),
    branch_id INT
);

CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(50),
    amount DECIMAL(10,2),
    issue_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- STEP 2: SNOWFLAKE DIMENSION TABLES
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    dob DATE,
    age INT,
    branch_id INT
);

CREATE TABLE dim_branch (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE dim_loan (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(50),
    amount DECIMAL(10,2),
    issue_date DATE,
    status VARCHAR(20)
);

-- STEP 3: FACT TABLE
CREATE TABLE fact_loan_payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    customer_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    branch_id INT
);

-- STEP 4: ETL PROCESS
-- 4.1: Load dim_branch
INSERT INTO dim_branch
SELECT DISTINCT branch_id, branch_name, city, region
FROM branches;

-- 4.2: Load dim_customer with age
INSERT INTO dim_customer
SELECT 
    customer_id, name, gender, dob, 
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM dob) AS age,
    branch_id
FROM customers;

-- 4.3: Load dim_loan
INSERT INTO dim_loan
SELECT loan_id, customer_id, loan_type, amount, issue_date, status
FROM loans;

-- 4.4: Load fact_loan_payments
INSERT INTO fact_loan_payments
SELECT 
    p.payment_id, p.loan_id, l.customer_id, p.payment_date, p.amount_paid, c.branch_id
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id
JOIN customers c ON l.customer_id = c.customer_id;

-- STEP 5: OLAP REPORTS

-- 5.1: Default rate by branch
SELECT 
    b.branch_name,
    COUNT(CASE WHEN l.status = 'defaulted' THEN 1 END) AS defaulted_loans,
    COUNT(*) AS total_loans,
    ROUND(COUNT(CASE WHEN l.status = 'defaulted' THEN 1 END) * 100.0 / COUNT(*), 2) AS default_rate_percent
FROM dim_loan l
JOIN dim_customer c ON l.customer_id = c.customer_id
JOIN dim_branch b ON c.branch_id = b.branch_id
GROUP BY b.branch_name;

-- 5.2: Loan product performance (total disbursed and repayments)
SELECT 
    loan_type,
    COUNT(*) AS num_loans,
    SUM(amount) AS total_dis_
