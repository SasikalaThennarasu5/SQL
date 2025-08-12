-- Task 20: Salary Management System

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE salaries (
    emp_id INT,
    month VARCHAR(7),
    base DECIMAL(10,2),
    bonus DECIMAL(10,2)
);

CREATE TABLE deductions (
    emp_id INT,
    month VARCHAR(7),
    reason VARCHAR(100),
    amount DECIMAL(10,2)
);

-- Sample Data
INSERT INTO employees VALUES (1, 'John'), (2, 'Jane');
INSERT INTO salaries VALUES (1, '2025-07', 3000, 200), (2, '2025-07', 3500, 300);
INSERT INTO deductions VALUES (1, '2025-07', 'Tax', 300);

-- Net salary calculation
SELECT e.name, s.month, (s.base + s.bonus - COALESCE(SUM(d.amount),0)) AS net_salary
FROM employees e
JOIN salaries s ON e.id = s.emp_id
LEFT JOIN deductions d ON e.id = d.emp_id AND s.month = d.month
GROUP BY e.name, s.month, s.base, s.bonus;