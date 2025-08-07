-- 1. Setup: Tables for employees, promotions, and managers
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    join_date DATE,
    manager_id INT
);

CREATE TABLE Promotions (
    promotion_id INT PRIMARY KEY,
    employee_id INT,
    promotion_date DATE,
    role VARCHAR(100),
    salary DECIMAL(10, 2),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 2. Insert sample data (optional)
-- (Only add if testing is needed)

-- 3. CTE: List promotions chronologically with ROW_NUMBER
WITH PromotionHistory AS (
    SELECT 
        p.employee_id,
        e.name,
        p.promotion_date,
        p.role,
        p.salary,
        ROW_NUMBER() OVER (PARTITION BY p.employee_id ORDER BY p.promotion_date) AS rn
    FROM Promotions p
    JOIN Employees e ON e.employee_id = p.employee_id
),

-- 4. CTE: Use LEAD to compare current and next promotion
PromotionComparison AS (
    SELECT 
        employee_id,
        name,
        promotion_date,
        role,
        salary,
        LEAD(role) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_role,
        LEAD(salary) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_salary,
        LEAD(promotion_date) OVER (PARTITION BY employee_id ORDER BY promotion_date) AS next_promotion_date
    FROM Promotions p
    JOIN Employees e ON e.employee_id = p.employee_id
),

-- 5. CTE: Calculate time between promotions
PromotionIntervals AS (
    SELECT
        employee_id,
        name,
        role,
        salary,
        promotion_date,
        next_role,
        next_salary,
        next_promotion_date,
        DATEDIFF(DAY, promotion_date, next_promotion_date) AS days_to_next_promotion
    FROM PromotionComparison
),

-- 6. Recursive CTE: Manager to employee chain
ManagerHierarchy AS (
    SELECT 
        employee_id,
        name,
        manager_id,
        CAST(name AS VARCHAR(MAX)) AS hierarchy_chain
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT 
        e.employee_id,
        e.name,
        e.manager_id,
        CAST(mh.hierarchy_chain + ' → ' + e.name AS VARCHAR(MAX))
    FROM Employees e
    JOIN ManagerHierarchy mh ON e.manager_id = mh.employee_id
),

-- 7. CTE: Time to first promotion for RANKing
FirstPromotion AS (
    SELECT 
        e.employee_id,
        e.name,
        e.join_date,
        MIN(p.promotion_date) AS first_promotion_date,
        DATEDIFF(DAY, e.join_date, MIN(p.promotion_date)) AS days_to_first_promotion
    FROM Employees e
    JOIN Promotions p ON e.employee_id = p.employee_id
    GROUP BY e.employee_id, e.name, e.join_date
),

-- 8. CTE: Rank employees by fastest first promotion
PromotionRanks AS (
    SELECT *,
           RANK() OVER (ORDER BY days_to_first_promotion ASC) AS promotion_rank
    FROM FirstPromotion
)

-- Final SELECTs (Examples)

-- A. View detailed promotion history with intervals
SELECT * FROM PromotionIntervals ORDER BY employee_id, promotion_date;

-- B. View hierarchy chains
SELECT * FROM ManagerHierarchy ORDER BY hierarchy_chain;

-- C. View fastest promoted employees
SELECT * FROM PromotionRanks ORDER BY promotion_rank;
