-- Tables
CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(150) UNIQUE CHECK (LENGTH(email) <= 100),
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE salaries (
  employee_id INT PRIMARY KEY,
  salary DECIMAL(10,2) CHECK (salary > 10000),
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Update salary
UPDATE salaries SET salary = 65000 WHERE employee_id = 2;

-- Drop constraint
ALTER TABLE employees DROP CONSTRAINT employees_email_check;

-- Transaction
BEGIN;
SAVEPOINT sp_bonus;
INSERT INTO salaries (employee_id, salary) VALUES (3, 15000);
-- If error
ROLLBACK TO sp_bonus;
COMMIT;
