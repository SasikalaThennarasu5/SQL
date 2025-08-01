-- Create Tables
CREATE TABLE officers (
    officer_id INT PRIMARY KEY,
    officer_name VARCHAR(100)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    client_id INT,
    officer_id INT,
    amount DECIMAL(12, 2),
    status VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (officer_id) REFERENCES officers(officer_id)
);

CREATE TABLE repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT,
    amount_paid DECIMAL(12, 2),
    payment_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Total loans issued per officer
SELECT o.officer_name, SUM(l.amount) AS total_issued
FROM officers o
JOIN loans l ON o.officer_id = l.officer_id
GROUP BY o.officer_name;

-- Clients with repayment > ₹1,00,000
SELECT c.client_name, SUM(r.amount_paid) AS total_repaid
FROM clients c
JOIN loans l ON c.client_id = l.client_id
JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY c.client_name
HAVING SUM(r.amount_paid) > 100000;

-- Officers approving more than 10 loans
SELECT o.officer_name, COUNT(l.loan_id) AS loan_count
FROM officers o
JOIN loans l ON o.officer_id = l.officer_id
GROUP BY o.officer_name
HAVING COUNT(l.loan_id) > 10;

-- INNER JOIN: clients ↔ loans ↔ officers
SELECT c.client_name, l.amount, o.officer_name
FROM clients c
JOIN loans l ON c.client_id = l.client_id
JOIN officers o ON l.officer_id = o.officer_id;

-- FULL OUTER JOIN: loans ↔ repayments (Emulated using UNION)
SELECT l.loan_id, l.amount AS loan_amount, r.amount_paid
FROM loans l
LEFT JOIN repayments r ON l.loan_id = r.loan_id
UNION
SELECT l.loan_id, l.amount AS loan_amount, r.amount_paid
FROM loans l
RIGHT JOIN repayments r ON l.loan_id = r.loan_id;

-- SELF JOIN: clients from same city
SELECT c1.client_name AS client1, c2.client_name AS client2, c1.city
FROM clients c1
JOIN clients c2 ON c1.city = c2.city AND c1.client_id <> c2.client_id;
