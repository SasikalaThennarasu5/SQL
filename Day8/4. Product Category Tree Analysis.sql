-- 1. Tables Setup

CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    parent_id INT -- NULL for top-level categories
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    created_at DATE,
    is_available BOOLEAN,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- 2. Recursive CTE to display full category tree (category → subcategory)

WITH RECURSIVE CategoryTree AS (
    SELECT 
        category_id,
        category_name,
        parent_id,
        category_name AS full_path,
        1 AS level
    FROM Categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT 
        c.category_id,
        c.category_name,
        c.parent_id,
        CONCAT(ct.full_path, ' > ', c.category_name) AS full_path,
        ct.level + 1
    FROM Categories c
    JOIN CategoryTree ct ON c.parent_id = ct.category_id
),

-- 3. CTE: Total product count per category
ProductCount AS (
    SELECT 
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS product_count
    FROM Categories c
    LEFT JOIN Products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name
),

-- 4. CTE: Ranking categories by total products
RankedCategories AS (
    SELECT 
        category_id,
        category_name,
        product_count,
        RANK() OVER (ORDER BY product_count DESC) AS product_rank
    FROM ProductCount
),

-- 5. CTE: Track category movement (products shifting between categories over time)
ProductMovement AS (
    SELECT 
        product_id,
        product_name,
        category_id,
        created_at,
        LAG(category_id) OVER (PARTITION BY product_id ORDER BY created_at) AS prev_category,
        LEAD(category_id) OVER (PARTITION BY product_id ORDER BY created_at) AS next_category
    FROM Products
),

-- 6. CTE: Product availability report
ProductAvailability AS (
    SELECT 
        c.category_name,
        p.product_id,
        p.product_name,
        p.is_available,
        CASE 
            WHEN p.is_available THEN 'In Stock'
            ELSE 'Out of Stock'
        END AS status
    FROM Products p
    JOIN Categories c ON c.category_id = p.category_id
)

-- Final Outputs

-- A. Display full category tree
SELECT * FROM CategoryTree ORDER BY full_path;

-- B. Categories ranked by product count
SELECT * FROM RankedCategories ORDER BY product_rank;

-- C. Products that have changed categories
SELECT * FROM ProductMovement 
WHERE prev_category IS DISTINCT FROM category_id OR next_category IS DISTINCT FROM category_id;

-- D. Product availability report
SELECT * FROM ProductAvailability ORDER BY category_name, product_name;
