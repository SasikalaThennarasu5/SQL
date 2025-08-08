-- 1. Table Creation
-- Table: users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Table: products
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL
);

-- Table: reviews
CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE (user_id, product_id)  -- prevent duplicate reviews
);
-- 2. Aggregate Ratings Using AVG and GROUP BY
-- Get average rating for each product
SELECT 
    p.id,
    p.name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.id) AS total_reviews
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name;
--  3. Top-Rated Products
-- Get top 5 highest-rated products with at least 3 reviews
SELECT 
    p.name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.id) AS total_reviews
FROM products p
JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
HAVING COUNT(r.id) >= 3
ORDER BY avg_rating DESC
LIMIT 5;
-- 4. Insert Review (with Duplicate Prevention)
-- Insert a new review
INSERT INTO reviews (user_id, product_id, rating, review)
VALUES (1, 2, 5, 'Excellent product!')
ON DUPLICATE KEY UPDATE 
    rating = VALUES(rating),
    review = VALUES(review),
    created_at = CURRENT_TIMESTAMP;

