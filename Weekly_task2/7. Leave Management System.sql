-- 1. Table Creation
-- Table: employees
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Table: leave_types
CREATE TABLE leave_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100) NOT NULL
);

-- Table: leave_requests
CREATE TABLE leave_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    FOREIGN KEY (emp_id) REFERENCES employees(id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id),
    CHECK (from_date <= to_date)
);
-- Check for overlapping approved leaves before inserting a new one
SELECT * FROM leave_requests
WHERE emp_id = 1
  AND status = 'Approved'
  AND (
    from_date BETWEEN '2025-08-10' AND '2025-08-15' OR
    to_date BETWEEN '2025-08-10' AND '2025-08-15' OR
    '2025-08-10' BETWEEN from_date AND to_date OR
    '2025-08-15' BETWEEN from_date AND to_date
);
-- 3. Aggregate Leaves by Employee
-- Total leaves taken by each employee
SELECT 
    e.name AS employee,
    lt.type_name AS leave_type,
    SUM(DATEDIFF(lr.to_date, lr.from_date) + 1) AS days_taken
FROM leave_requests lr
JOIN employees e ON lr.emp_id = e.id
JOIN leave_types lt ON lr.leave_type_id = lt.id
WHERE lr.status = 'Approved'
GROUP BY e.id, lt.id;
 -- 4. Sample Insert Statements
 -- Add sample leave types
INSERT INTO leave_types (type_name) VALUES ('Sick Leave'), ('Casual Leave');

-- Add a leave request
INSERT INTO leave_requests (emp_id, leave_type_id, from_date, to_date, status)
VALUES (1, 1, '2025-08-10', '2025-08-12', 'Pending');
