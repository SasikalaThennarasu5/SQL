-- Food Delivery Tracker
CREATE TABLE orders (
    id INT PRIMARY KEY,
    restaurant_id INT,
    user_id INT,
    placed_at DATETIME,
    delivered_at DATETIME
);

CREATE TABLE delivery_agents (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE deliveries (
    order_id INT,
    agent_id INT
);

-- Delivery time analysis (minutes)
SELECT o.id, TIMESTAMPDIFF(MINUTE, o.placed_at, o.delivered_at) AS delivery_minutes
FROM orders o
WHERE o.delivered_at IS NOT NULL;

-- Agent workload
SELECT d.agent_id, da.name, COUNT(*) AS deliveries_count
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.id
GROUP BY d.agent_id, da.name;
