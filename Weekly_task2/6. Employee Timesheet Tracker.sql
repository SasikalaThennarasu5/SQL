-- 1. Table Creation
-- Table: employees
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept VARCHAR(100)
);

-- Table: projects
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL
);

-- Table: timesheets
CREATE TABLE timesheets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    project_id INT NOT NULL,
    hours DECIMAL(5, 2) NOT NULL CHECK (hours >= 0),
    date DATE NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employees(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);
 -- 2. JOINs to Fetch Timesheet per Project
-- View all timesheet entries with employee and project info
SELECT 
    t.date,
    e.name AS employee,
    e.dept,
    p.name AS project,
    t.hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
ORDER BY t.date DESC;
-- 3. Weekly or Monthly Hours by Employee
-- Weekly: Total hours logged by each employee for current week
SELECT 
    e.name AS employee,
    SUM(t.hours) AS weekly_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
WHERE YEARWEEK(t.date, 1) = YEARWEEK(CURDATE(), 1)
GROUP BY e.id;

-- Monthly: Total hours per employee for current month
SELECT 
    e.name AS employee,
    SUM(t.hours) AS monthly_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
WHERE MONTH(t.date) = MONTH(CURDATE()) AND YEAR(t.date) = YEAR(CURDATE())
GROUP BY e.id;
-- 4. Total Hours Per Project Per Employee
SELECT 
    e.name AS employee,
    p.name AS project,
    SUM(t.hours) AS total_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
GROUP BY e.id, p.id
ORDER BY e.name, p.name;



