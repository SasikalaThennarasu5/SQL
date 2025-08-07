-- 1. Create employee table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    position VARCHAR(100),
    manager_id INT,
    start_date DATE
);

-- 2. Insert sample data
INSERT INTO employees (emp_id, emp_name, position, manager_id, start_date) VALUES
(1, 'Alice', 'CEO', NULL, '2020-01-01'),
(2, 'Bob', 'VP of Sales', 1, '2020-03-01'),
(3, 'Carol', 'Sales Manager', 2, '2020-06-01'),
(4, 'Dave', 'Sales Executive', 3, '2021-01-01'),
(5, 'Eve', 'VP of Engineering', 1, '2020-03-15'),
(6, 'Frank', 'Engineering Manager', 5, '2020-08-01'),
(7, 'Grace', 'Engineer', 6, '2021-02-01'),
(8, 'Heidi', 'Engineer', 6, '2021-03-01'),
(9, 'Ivan', 'Engineering Intern', 7, '2022-01-01'),
(10, 'Judy', 'HR Manager', 1, '2020-05-01');

-- 3. Recursive CTE: Organization Chart (employee → manager → director)
WITH RECURSIVE org_chart AS (
    SELECT 
        emp_id,
        emp_name,
        position,
        manager_id,
        1 AS level,
        emp_name AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT 
        e.emp_id,
        e.emp_name,
        e.position,
        e.manager_id,
        oc.level + 1,
        CONCAT(oc.path, ' → ', e.emp_name)
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.emp_id
)
SELECT * FROM org_chart
ORDER BY level, emp_name;

-- 4. Row number: Order of direct reports under each manager
SELECT 
    manager_id,
    emp_name,
    position,
    ROW_NUMBER() OVER (PARTITION BY manager_id ORDER BY start_date) AS report_order
FROM employees
WHERE manager_id IS NOT NULL;

-- 5. Rank: Managers with most subordinates
SELECT 
    manager_id,
    COUNT(*) AS subordinate_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS manager_rank
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id;

-- 6. Lead/Lag: Leadership change detection based on start_date
SELECT 
    emp_id,
    emp_name,
    manager_id,
    position,
    start_date,
    LAG(manager_id) OVER (PARTITION BY position ORDER BY start_date) AS prev_manager,
    LEAD(manager_id) OVER (PARTITION BY position ORDER BY start_date) AS next_manager
FROM employees
WHERE manager_id IS NOT NULL;
