-- Task 16: Expense Tracker

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE categories (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE expenses (
    id INT PRIMARY KEY,
    user_id INT,
    category_id INT,
    amount DECIMAL(10,2),
    date DATE
);

-- Sample Data
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
INSERT INTO categories VALUES (1, 'Food'), (2, 'Transport');
INSERT INTO expenses VALUES (1, 1, 1, 150.00, '2025-06-01');

-- Monthly total per category
SELECT c.name, SUM(e.amount) AS total
FROM expenses e
JOIN categories c ON e.category_id = c.id
GROUP BY c.name;