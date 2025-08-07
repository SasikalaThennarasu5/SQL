-- 1. Setup: Tables for locations and sales
CREATE TABLE Locations (
    location_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_id INT, -- NULL for regions, region_id for states, state_id for cities
    type VARCHAR(10) -- 'region', 'state', 'city'
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    location_id INT,
    sale_date DATE,
    amount DECIMAL(10, 2),
    FOREIGN KEY (location_id) REFERENCES Locations(location_id)
);

-- 2. Recursive CTE to build full location hierarchy (region > state > city)
WITH RECURSIVE LocationHierarchy AS (
    SELECT 
        location_id,
        name,
        parent_id,
        type,
        name AS full_path
    FROM Locations
    WHERE parent_id IS NULL

    UNION ALL

    SELECT 
        l.location_id,
        l.name,
        l.parent_id,
        l.type,
        CONCAT(lh.full_path, ' > ', l.name) AS full_path
    FROM Locations l
    JOIN LocationHierarchy lh ON l.parent_id = lh.location_id
),

-- 3. Weekly and Monthly Performance CTEs
WeeklySales AS (
    SELECT 
        l.location_id,
        DATEPART(YEAR, s.sale_date) AS sale_year,
        DATEPART(WEEK, s.sale_date) AS sale_week,
        SUM(s.amount) AS weekly_total
    FROM Sales s
    JOIN Locations l ON l.location_id = s.location_id
    GROUP BY l.location_id, DATEPART(YEAR, s.sale_date), DATEPART(WEEK, s.sale_date)
),

MonthlySales AS (
    SELECT 
        l.location_id,
        DATEPART(YEAR, s.sale_date) AS sale_year,
        DATEPART(MONTH, s.sale_date) AS sale_month,
        SUM(s.amount) AS monthly_total
    FROM Sales s
    JOIN Locations l ON l.location_id = s.location_id
    GROUP BY l.location_id, DATEPART(YEAR, s.sale_date), DATEPART(MONTH, s.sale_date)
),

-- 4. Rank regions by weekly sales
RegionWeeklyRanked AS (
    SELECT 
        l.location_id,
        l.name AS region_name,
        ws.sale_year,
        ws.sale_week,
        ws.weekly_total,
        RANK() OVER (PARTITION BY ws.sale_year, ws.sale_week ORDER BY ws.weekly_total DESC) AS weekly_rank,
        DENSE_RANK() OVER (PARTITION BY ws.sale_year, ws.sale_week ORDER BY ws.weekly_total DESC) AS dense_weekly_rank
    FROM WeeklySales ws
    JOIN Locations l ON l.location_id = ws.location_id
    WHERE l.type = 'region'
),

-- 5. Compare current week's revenue with last using LAG
RegionWeeklyCompare AS (
    SELECT 
        location_id,
        region_name,
        sale_year,
        sale_week,
        weekly_total,
        LAG(weekly_total) OVER (PARTITION BY location_id ORDER BY sale_year, sale_week) AS prev_week_total,
        weekly_rank,
        dense_weekly_rank
    FROM RegionWeeklyRanked
),

-- 6. Flag top-performing regions (top 3)
TopPerformers AS (
    SELECT *,
        CASE 
            WHEN weekly_rank <= 3 THEN 'Top Performer'
            ELSE 'Normal'
        END AS performance_flag
    FROM RegionWeeklyCompare
)

-- Final SELECTs

-- A. Hierarchical location path
SELECT * FROM LocationHierarchy ORDER BY full_path;

-- B. Weekly sales with previous week comparison
SELECT * FROM RegionWeeklyCompare ORDER BY sale_year DESC, sale_week DESC, weekly_rank;

-- C. Top performing regions flagged
SELECT * FROM TopPerformers WHERE performance_flag = 'Top Performer' ORDER BY sale_year DESC, sale_week DESC, weekly_total DESC;

-- D. Monthly sales summary
SELECT 
    l.name AS location_name,
    l.type,
    ms.sale_year,
    ms.sale_month,
    ms.monthly_total
FROM MonthlySales ms
JOIN Locations l ON l.location_id = ms.location_id
ORDER BY ms.sale_year DESC, ms.sale_month DESC, ms.monthly_total DESC;
