-- Task 19: Loan Repayment Tracker

CREATE TABLE loans (
    id INT PRIMARY KEY,
    user_id INT,
    principal DECIMAL(10,2),
    interest_rate DECIMAL(5,2)
);

CREATE TABLE payments (
    loan_id INT,
    amount DECIMAL(10,2),
    paid_on DATE
);

-- Sample Data
INSERT INTO loans VALUES (1, 1, 50000, 5.0);
INSERT INTO payments VALUES (1, 1000, '2025-01-01'), (1, 2000, '2025-02-01');

-- Calculate paid vs total
SELECT l.id, SUM(p.amount) AS total_paid, (l.principal + (l.principal * l.interest_rate / 100)) AS total_due
FROM loans l
LEFT JOIN payments p ON l.id = p.loan_id
GROUP BY l.id;