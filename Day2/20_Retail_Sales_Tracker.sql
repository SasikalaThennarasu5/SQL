-- Items with price > 500 and quantity >= 2
SELECT * FROM sales 
WHERE price > 500 AND quantity >= 2;

-- Item names containing 'Pro'
SELECT * FROM sales 
WHERE item_name LIKE '%Pro%';

-- Sales with NULL quantity
SELECT * FROM sales 
WHERE quantity IS NULL;

-- List of distinct product categories
SELECT DISTINCT category 
FROM sales;

-- Sort sales by sale_date DESC, then price DESC
SELECT * FROM sales 
ORDER BY sale_date DESC, price DESC;
