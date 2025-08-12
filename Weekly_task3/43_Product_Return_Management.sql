-- Product Return Management
CREATE TABLE orders (
    id INT PRIMARY KEY,
    user_id INT,
    product_id INT
);

CREATE TABLE returns (
    id INT PRIMARY KEY,
    order_id INT,
    reason TEXT,
    status VARCHAR(50)
);

-- Join orders with returns
SELECT o.id AS order_id, r.id AS return_id, r.status, r.reason
FROM orders o
LEFT JOIN returns r ON o.id = r.order_id;

-- Returns status report
SELECT status, COUNT(*) AS count_by_status
FROM returns
GROUP BY status;
