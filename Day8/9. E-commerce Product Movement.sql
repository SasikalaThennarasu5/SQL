-- E-commerce Product Movement Tracking

-- Table Setup
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample Data (You can extend as needed)
INSERT INTO products VALUES 
(1, 'Laptop'), (2, 'Mouse'), (3, 'Keyboard'), (4, 'Monitor');

INSERT INTO sales VALUES 
(1, 1, 10, '2025-07-01'), 
(2, 1, 5, '2025-07-02'), 
(3, 2, 20, '2025-07-01'),
(4, 3, 15, '2025-07-08'),
(5, 1, 10, '2025-07-10'),
(6, 2, 30, '2025-07-15'),
(7, 4, 25, '2025-07-15');

-- 1. Weekly Product Sales Summary using CTE
WITH weekly_sales AS (
    SELECT 
        product_id,
        DATE_TRUNC('week', sale_date) AS week_start,
        SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY product_id, DATE_TRUNC('week', sale_date)
),

-- 2. Weekly Product Ranking using RANK and DENSE_RANK
ranked_products AS (
    SELECT *,
        RANK() OVER (PARTITION BY week_start ORDER BY total_quantity DESC) AS sales_rank,
        DENSE_RANK() OVER (PARTITION BY week_start ORDER BY total_quantity DESC) AS dense_sales_rank
    FROM weekly_sales
),

-- 3. Add Previous Week Rank using LAG
rank_with_lag AS (
    SELECT *,
        LAG(sales_rank) OVER (PARTITION BY product_id ORDER BY week_start) AS prev_week_rank
    FROM ranked_products
)

-- Final Output: Weekly Top Products with Rank Movement
SELECT 
    p.name,
    r.week_start,
    r.total_quantity,
    r.sales_rank,
    r.dense_sales_rank,
    r.prev_week_rank,
    (r.prev_week_rank - r.sales_rank) AS rank_change
FROM rank_with_lag r
JOIN products p ON r.product_id = p.product_id
ORDER BY r.week_start, r.sales_rank;
