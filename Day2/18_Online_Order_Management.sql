-- Orders placed in the last 7 days
SELECT * FROM orders 
WHERE order_date BETWEEN DATE('now', '-7 days') AND DATE('now');

-- Customers with names starting with 'R'
SELECT * FROM orders 
WHERE customer_name LIKE 'R%';

-- Orders with NULL status
SELECT * FROM orders 
WHERE status IS NULL;

-- List of unique delivery addresses
SELECT DISTINCT address 
FROM orders;

-- Sort orders by order_date descending, then total descending
SELECT * FROM orders 
ORDER BY order_date DESC, total DESC;
