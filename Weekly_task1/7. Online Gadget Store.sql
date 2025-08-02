-- Create tables
CREATE TABLE categories (
  category_id INT PRIMARY KEY,
  category_name VARCHAR(50)
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  price DECIMAL(10,2),
  category_id INT,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  location VARCHAR(100)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  quantity INT,
  order_date DATE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample data
INSERT INTO categories VALUES
(1, 'Smartphones'),
(2, 'Laptops'),
(3, 'Accessories'),
(4, 'Tablets');

INSERT INTO products VALUES
(101, 'iPhone 14', 999.99, 1),
(102, 'MacBook Pro', 1999.99, 2),
(103, 'USB-C Charger', 29.99, 3),
(104, 'iPad Air', 599.99, 4),
(105, 'Wireless Mouse', 49.99, 3);

INSERT INTO customers VALUES
(1, 'Alice', 'New York'),
(2, 'Bob', 'Los Angeles'),
(3, 'Charlie', 'Chicago'),
(4, 'Diana', 'New York'),
(5, 'Ethan', 'Houston');

INSERT INTO orders VALUES
(201, 1, 101, 1, '2025-07-01'),
(202, 2, 102, 1, '2025-07-03'),
(203, 1, 103, 2, '2025-07-05'),
(204, 3, 104, 1, '2025-07-06'),
(205, 1, 105, 1, '2025-07-08'),
(206, 2, 101, 1, '2025-07-10'),
(207, 3, 103, 3, '2025-07-11'),
(208, 4, 102, 1, '2025-07-12'),
(209, 5, 104, 1, '2025-07-13'),
(210, 4, 101, 1, '2025-07-14');

-- 1. Get unique customer locations
SELECT DISTINCT location FROM customers;

-- 2. High-value orders (between $1000 and $2500)
SELECT o.order_id, c.name, p.product_name, (o.quantity * p.price) AS total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE (o.quantity * p.price) BETWEEN 1000 AND 2500;

-- 3. Customers who never ordered accessories
SELECT name FROM customers
WHERE customer_id NOT IN (
  SELECT DISTINCT o.customer_id
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  WHERE p.category_id = 3
);

-- 4. Maximum and Minimum order value
SELECT 
  MAX(o.quantity * p.price) AS max_order_value,
  MIN(o.quantity * p.price) AS min_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;

-- 5. Full product category mapping
SELECT p.product_name, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- 6. Most purchased products (total quantity)
SELECT p.product_name, SUM(o.quantity) AS total_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;

-- 7. Label customers as VIP (>=3 orders) or Regular
SELECT c.name,
  COUNT(o.order_id) AS total_orders,
  CASE
    WHEN COUNT(o.order_id) >= 3 THEN 'VIP'
    ELSE 'Regular'
  END AS customer_type
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name;
