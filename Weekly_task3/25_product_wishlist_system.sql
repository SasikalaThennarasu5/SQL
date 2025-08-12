-- Task 25: Product Wishlist System

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE wishlist (
    user_id INT,
    product_id INT
);

-- Sample Data
INSERT INTO users VALUES (1, 'Alice');
INSERT INTO products VALUES (1, 'Laptop'), (2, 'Phone');
INSERT INTO wishlist VALUES (1, 1), (1, 2);

-- Popular wishlist items
SELECT p.name, COUNT(w.user_id) AS wishlist_count
FROM wishlist w
JOIN products p ON w.product_id = p.id
GROUP BY p.name;