
-- Table: categories
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Table: brands
CREATE TABLE brands (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Table: products
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    image_url VARCHAR(255),
    category_id INT,
    brand_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);

-- Indexes for better filtering performance
CREATE INDEX idx_price ON products(price);
CREATE INDEX idx_category ON products(category_id);
CREATE INDEX idx_brand ON products(brand_id);

-- Insert categories
INSERT INTO categories (name) VALUES 
('Electronics'), 
('Apparel');

-- Insert brands
INSERT INTO brands (name) VALUES 
('Apple'), 
('Nike');

-- Insert products
INSERT INTO products (name, description, price, stock, image_url, category_id, brand_id) VALUES
('iPhone 15', 'Latest iPhone with advanced features', 999.99, 50, 'iphone15.jpg', 1, 1),
('AirPods Pro', 'Wireless noise-cancelling earbuds', 249.99, 100, 'airpods.jpg', 1, 1),
('Nike Air Max', 'Comfortable running shoes', 129.99, 70, 'airmax.jpg', 2, 2);

-- Queries
-- a. Products in Electronics category
SELECT p.name, p.price, p.stock, c.name AS category, b.name AS brand
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN brands b ON p.brand_id = b.id
WHERE c.name = 'Electronics';

-- b. Products by Nike brand
SELECT p.name, p.price, p.stock, c.name AS category, b.name AS brand
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN brands b ON p.brand_id = b.id
WHERE b.name = 'Nike';

-- c. Products in price range
SELECT name, price, stock 
FROM products 
WHERE price BETWEEN 100 AND 500;

-- d. Products filtered by category and brand
SELECT p.name, p.price, c.name AS category, b.name AS brand
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN brands b ON p.brand_id = b.id
WHERE c.name = 'Apparel' AND b.name = 'Nike';
