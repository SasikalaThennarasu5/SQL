-- Employee Directory

-- Salary > 50000 in Sales or Marketing
SELECT name, salary, department FROM employees WHERE salary > 50000 AND department IN ('Sales', 'Marketing');

-- List unique departments
SELECT DISTINCT department FROM employees;

-- Employees with names ending in 'an'
SELECT * FROM employees WHERE name LIKE '%an';

-- Employees with no manager
SELECT * FROM employees WHERE manager_id IS NULL;

-- Salaries between 40000 and 80000
SELECT * FROM employees WHERE salary BETWEEN 40000 AND 80000;

-- Sort by department ASC, salary DESC
SELECT * FROM employees ORDER BY department ASC, salary DESC;
