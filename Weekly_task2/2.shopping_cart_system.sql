
-- Table: users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Table: carts
CREATE TABLE carts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Table: cart_items
CREATE TABLE cart_items (
    cart_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES carts(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Sample Queries

-- 1. Get product details in a user's cart
SELECT 
    u.name AS user_name,
    p.name AS product_name,
    p.price,
    ci.quantity,
    (p.price * ci.quantity) AS total_price
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
JOIN users u ON c.user_id = u.id
JOIN products p ON ci.product_id = p.id
WHERE u.id = 1;

-- 2. Calculate total cart value for a user
SELECT 
    SUM(p.price * ci.quantity) AS cart_total
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
JOIN users u ON c.user_id = u.id
JOIN products p ON ci.product_id = p.id
WHERE u.id = 1;

-- 3. Add a product to cart
INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES (1, 2, 3)
ON DUPLICATE KEY UPDATE quantity = quantity + 3;

-- 4. Update quantity of a cart item
UPDATE cart_items
SET quantity = 5
WHERE cart_id = 1 AND product_id = 2;

-- 5. Remove an item from the cart
DELETE FROM cart_items
WHERE cart_id = 1 AND product_id = 2;
