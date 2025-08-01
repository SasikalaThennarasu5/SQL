-- Create Tables
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_number VARCHAR(15)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    supplier_id INT,
    price DECIMAL(10, 2),
    quantity_in_stock INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE purchase_orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    order_date DATE,
    quantity_ordered INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Products that are low in stock (below 20 units)
SELECT product_name, quantity_in_stock
FROM products
WHERE quantity_in_stock < 20;

-- Total quantity ordered for each product
SELECT p.product_name, SUM(po.quantity_ordered) AS total_ordered
FROM purchase_orders po
JOIN products p ON po.product_id = p.product_id
GROUP BY p.product_name;

-- Suppliers who provide more than 2 products
SELECT s.supplier_name, COUNT(p.product_id) AS product_count
FROM suppliers s
JOIN products p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_name
HAVING COUNT(p.product_id) > 2;

-- Average price of products per supplier
SELECT s.supplier_name, AVG(p.price) AS avg_price
FROM suppliers s
JOIN products p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_name;

-- INNER JOIN: Product with supplier info
SELECT p.product_name, s.supplier_name, p.price, p.quantity_in_stock
FROM products p
JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- LEFT JOIN: Products never ordered
SELECT p.product_name
FROM products p
LEFT JOIN purchase_orders po ON p.product_id = po.product_id
WHERE po.product_id IS NULL;
