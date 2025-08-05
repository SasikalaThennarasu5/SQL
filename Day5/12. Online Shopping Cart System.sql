12. Online Shopping Cart System
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2),
    stock INT
);

CREATE TABLE cart_items (
    cart_id INT PRIMARY KEY,
    user_id INT,
    product_id INT,
    quantity INT CHECK (quantity BETWEEN 1 AND 10),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    total DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Update quantity
UPDATE cart_items SET quantity = 3 WHERE cart_id = 1;

-- Delete abandoned carts
DELETE FROM cart_items WHERE cart_id IN (
    SELECT cart_id FROM cart_items WHERE CURRENT_DATE - INTERVAL '7 days' > CURRENT_DATE
);

-- Drop & re-add constraint on uniqueness
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_unique;
ALTER TABLE cart_items ADD CONSTRAINT cart_unique UNIQUE (user_id, product_id);

-- Transaction: order, stock, clear cart
BEGIN;
INSERT INTO orders VALUES (1, 1, 999.99);
UPDATE products SET stock = stock - 1 WHERE product_id = 1;
DELETE FROM cart_items WHERE user_id = 1;
COMMIT;