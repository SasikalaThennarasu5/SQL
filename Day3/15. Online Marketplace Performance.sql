-- Create Tables
CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE buyers (
    buyer_id INT PRIMARY KEY,
    buyer_name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    seller_id INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    buyer_id INT,
    product_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Revenue generated per seller
SELECT s.seller_name, SUM(p.price * pu.quantity) AS total_revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN purchases pu ON p.product_id = pu.product_id
GROUP BY s.seller_name;

-- Most purchased products
SELECT p.product_name, COUNT(pu.purchase_id) AS total_purchases
FROM products p
JOIN purchases pu ON p.product_id = pu.product_id
GROUP BY p.product_name
ORDER BY total_purchases DESC;

-- Sellers with revenue > ₹1,00,000
SELECT s.seller_name, SUM(p.price * pu.quantity) AS revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN purchases pu ON p.product_id = pu.product_id
GROUP BY s.seller_name
HAVING SUM(p.price * pu.quantity) > 100000;

-- INNER JOIN purchases ↔ products ↔ sellers
SELECT pu.purchase_id, b.buyer_name, p.product_name, s.seller_name
FROM purchases pu
JOIN products p ON pu.product_id = p.product_id
JOIN sellers s ON p.seller_id = s.seller_id
JOIN buyers b ON pu.buyer_id = b.buyer_id;

-- LEFT JOIN: sellers ↔ products
SELECT s.seller_name, p.product_name
FROM sellers s
LEFT JOIN products p ON s.seller_id = p.seller_id;

-- SELF JOIN: sellers from the same city
SELECT s1.seller_name AS seller1, s2.seller_name AS seller2, s1.city
FROM sellers s1
JOIN sellers s2 ON s1.city = s2.city
    AND s1.seller_id <> s2.seller_id;
