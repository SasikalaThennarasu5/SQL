-- 1. Create Tables
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT,
    department_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    emp_id INT,
    review_date DATE,
    score DECIMAL(5,2),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- 2. Insert Sample Data
INSERT INTO departments VALUES 
(1, 'Engineering'),
(2, 'Marketing');

INSERT INTO employees VALUES 
(1, 'John', NULL, 1),
(2, 'Alice', 1, 1),
(3, 'Bob', 1, 2),
(4, 'Carol', 2, 2);

INSERT INTO reviews VALUES 
(1, 2, '2024-06-01', 85),
(2, 2, '2025-06-01', 90),
(3, 3, '2025-06-01', 78),
(4, 4, '2025-07-01', 88);

-- 3. SELF JOIN: Employees & Managers
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- 4. Review entries with ROW_NUMBER()
-- (Requires database support like PostgreSQL/SQL Server)
-- SELECT emp_id, review_date, score,
--   ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY review_date DESC) AS row_num
-- FROM reviews;

-- 5. Average Score per Department
SELECT d.department_name, AVG(r.score) AS avg_score
FROM reviews r
JOIN employees e ON r.emp_id = e.emp_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 6. CASE for Rating Labels
SELECT e.name, r.score,
  CASE
    WHEN r.score >= 85 THEN 'Excellent'
    WHEN r.score >= 70 THEN 'Good'
    ELSE 'Average'
  END AS rating
FROM reviews r
JOIN employees e ON r.emp_id = e.emp_id;

-- 7. Completed Reviews Only
SELECT * FROM reviews WHERE score IS NOT NULL;

-- 8. Latest Review per Employee (Subquery in SELECT)
SELECT e.name,
  (SELECT MAX(review_date) FROM reviews r2 WHERE r2.emp_id = e.emp_id) AS latest_review
FROM employees e;

-- 9. Sort by Score & Department
SELECT e.name, d.department_name, r.score
FROM reviews r
JOIN employees e ON r.emp_id = e.emp_id
JOIN departments d ON e.department_id = d.department_id
ORDER BY r.score DESC, d.department_name;
