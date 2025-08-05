-- Create tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(6,2),
    available BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    item_id INT,
    quantity INT CHECK (quantity <= 10),
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE bills (
    bill_id INT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2),
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Update item availability after order
UPDATE menu_items SET available = FALSE WHERE item_id = 2;

-- Delete unpaid orders after timeout (example: 30 minutes)
DELETE FROM orders
WHERE order_time < NOW() - INTERVAL '30 minutes'
AND order_id NOT IN (SELECT order_id FROM bills WHERE paid = TRUE);

-- Drop and reapply NOT NULL constraint on a column (e.g., table number)
ALTER TABLE orders DROP COLUMN table_number;
ALTER TABLE orders ADD COLUMN table_number INT;
-- Re-apply NOT NULL
ALTER TABLE orders ALTER COLUMN table_number SET NOT NULL;

-- Transaction: Create order and bill together
BEGIN;
  INSERT INTO orders (order_id, customer_id, item_id, quantity, table_number)
  VALUES (101, 1, 2, 2, 5);

  INSERT INTO bills (bill_id, order_id, amount)
  VALUES (201, 101, 500.00);
COMMIT;
