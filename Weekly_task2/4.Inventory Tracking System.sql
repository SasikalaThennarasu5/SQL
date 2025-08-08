-- 1. Table Creation
-- Table: suppliers
CREATE TABLE suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Table: products (with stock column)
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- Table: inventory_logs
CREATE TABLE inventory_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    supplier_id INT,
    action ENUM('IN', 'OUT') NOT NULL,
    qty INT NOT NULL CHECK (qty > 0),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);
-- 2. Trigger to Auto-Update Stock
DELIMITER //

CREATE TRIGGER update_stock_after_inventory_log
AFTER INSERT ON inventory_logs
FOR EACH ROW
BEGIN
    IF NEW.action = 'IN' THEN
        UPDATE products SET stock = stock + NEW.qty WHERE id = NEW.product_id;
    ELSEIF NEW.action = 'OUT' THEN
        UPDATE products SET stock = stock - NEW.qty WHERE id = NEW.product_id;
    END IF;
END;
//

DELIMITER ;
--  3. Reorder Logic: Stock Status Query
SELECT 
    p.id,
    p.name,
    p.stock,
    CASE 
        WHEN p.stock < 10 THEN 'Low Stock - Reorder Needed'
        ELSE 'Sufficient Stock'
    END AS stock_status
FROM products p;
--4. Sample Insert Statements
-- Add a supplier
INSERT INTO suppliers (name) VALUES ('Generic Supplier');

-- Add a product
INSERT INTO products (name, stock) VALUES ('Baby Shampoo', 0);

-- Log incoming stock
INSERT INTO inventory_logs (product_id, supplier_id, action, qty) 
VALUES (1, 1, 'IN', 100);

-- Log outgoing stock (e.g., sold or damaged)
INSERT INTO inventory_logs (product_id, supplier_id, action, qty) 
VALUES (1, NULL, 'OUT', 25);

