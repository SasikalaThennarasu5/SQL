-- Inventory Expiry Tracker
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE batches (
    id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    expiry_date DATE
);

-- Expired stock
SELECT b.id, p.name, b.quantity, b.expiry_date FROM batches b JOIN products p ON b.product_id = p.id WHERE b.expiry_date < CURDATE();

-- Remaining (non-expired) stock
SELECT p.id, p.name, SUM(b.quantity) AS remaining_qty FROM products p JOIN batches b ON p.id = b.product_id WHERE b.expiry_date >= CURDATE() GROUP BY p.id, p.name;
