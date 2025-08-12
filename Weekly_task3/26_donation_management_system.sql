-- Task 26: Donation Management System

CREATE TABLE donors (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE causes (
    id INT PRIMARY KEY,
    title VARCHAR(100)
);

CREATE TABLE donations (
    id INT PRIMARY KEY,
    donor_id INT,
    cause_id INT,
    amount DECIMAL(10,2),
    donated_at DATE
);

-- Sample Data
INSERT INTO donors VALUES (1, 'John');
INSERT INTO causes VALUES (1, 'Education Fund');
INSERT INTO donations VALUES (1, 1, 1, 500.00, '2025-08-01');

-- Sum per cause
SELECT c.title, SUM(d.amount) AS total_donated
FROM donations d
JOIN causes c ON d.cause_id = c.id
GROUP BY c.title;