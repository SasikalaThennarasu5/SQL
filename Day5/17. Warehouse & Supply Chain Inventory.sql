17. Warehouse & Supply Chain Inventory
CREATE TABLE suppliers (
  supplier_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  stock INT DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE batches (
  batch_id INT PRIMARY KEY,
  product_id INT,
  manufactured_date DATE,
  expiry_date DATE,
  CHECK (expiry_date > manufactured_date),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE deliveries (
  delivery_id INT PRIMARY KEY,
  batch_id INT,
  supplier_id INT,
  quantity INT NOT NULL,
  FOREIGN KEY (batch_id) REFERENCES batches(batch_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Drop & recreate FOREIGN KEY on deliveries
ALTER TABLE deliveries DROP CONSTRAINT deliveries_supplier_id_fkey;
ALTER TABLE deliveries ADD FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id);

-- Delete expired batches
DELETE FROM batches WHERE expiry_date < CURRENT_DATE;

-- Insert delivery & update product stock in transaction
BEGIN;
INSERT INTO deliveries (delivery_id, batch_id, supplier_id, quantity) VALUES (1, 101, 1, 50);
UPDATE products SET stock = stock + 50 WHERE product_id = (SELECT product_id FROM batches WHERE batch_id = 101);
COMMIT;
