-- Task 17: Invoice Generator

CREATE TABLE clients (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE invoices (
    id INT PRIMARY KEY,
    client_id INT,
    date DATE
);

CREATE TABLE invoice_items (
    invoice_id INT,
    description VARCHAR(200),
    quantity INT,
    rate DECIMAL(10,2)
);

-- Sample Data
INSERT INTO clients VALUES (1, 'ABC Corp');
INSERT INTO invoices VALUES (1, 1, '2025-07-01');
INSERT INTO invoice_items VALUES (1, 'Product A', 2, 100.00), (1, 'Product B', 1, 150.00);

-- Subtotal per invoice
SELECT i.id, SUM(ii.quantity * ii.rate) AS subtotal
FROM invoices i
JOIN invoice_items ii ON i.id = ii.invoice_id
GROUP BY i.id;