-- Product Inventory Dashboard

-- Products priced between 100 and 1000
SELECT name, category, price FROM products WHERE price BETWEEN 100 AND 1000;

-- Products with "phone" in name
SELECT * FROM products WHERE name LIKE '%phone%';

-- Products with NULL description
SELECT * FROM products WHERE description IS NULL;

-- List all unique suppliers
SELECT DISTINCT supplier FROM products;

-- Stock is 0 OR price > 5000
SELECT * FROM products WHERE stock = 0 OR price > 5000;

-- Sort by category and price DESC
SELECT * FROM products ORDER BY category, price DESC;
