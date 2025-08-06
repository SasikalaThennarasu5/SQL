-- 2.1 Tables (3NF Normalized)
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150),
    category_id INT,
    supplier_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    quantity_in_stock INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2.2 Denormalized reporting table
CREATE TABLE product_sales_report (
    product_id INT,
    product_name VARCHAR(150),
    category_name VARCHAR(100),
    total_sales INT
);

INSERT INTO product_sales_report
SELECT 
    p.product_id, p.product_name, c.name,
    SUM(oi.quantity) AS total_sales
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, c.name;

-- 2.3 Indexing
CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_category_id ON products(category_id);
CREATE INDEX idx_supplier_id ON products(supplier_id);

-- 2.4 EXPLAIN for product search with filters
EXPLAIN SELECT * FROM products WHERE product_name LIKE '%phone%' AND category_id = 2;

-- 2.5 Subquery: Products with highest sales
SELECT product_id, product_name
FROM products
WHERE product_id = (
    SELECT product_id 
    FROM order_items
    GROUP BY product_id
    ORDER BY SUM(quantity) DESC
    LIMIT 1
);

-- 2.6 JOIN performance comparison
-- Without index
EXPLAIN SELECT p.product_name, s.name 
FROM products p 
JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- With index (see idx_supplier_id above)
-- Same query, EXPLAIN will show improved execution plan

-- 2.7 Top 10 most ordered products using LIMIT
SELECT p.product_name, SUM(oi.quantity) AS total_ordered
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_ordered DESC
LIMIT 10;
