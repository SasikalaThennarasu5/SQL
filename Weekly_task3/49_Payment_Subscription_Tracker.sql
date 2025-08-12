-- Payment Subscription Tracker
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE subscriptions (
    id INT PRIMARY KEY,
    user_id INT,
    plan_name VARCHAR(255),
    start_date DATE,
    renewal_cycle VARCHAR(50)
);

-- Example next renewal (simplified)
SELECT s.*,
CASE WHEN s.renewal_cycle = 'monthly' THEN DATE_ADD(s.start_date, INTERVAL 1 MONTH)
     WHEN s.renewal_cycle = 'yearly' THEN DATE_ADD(s.start_date, INTERVAL 1 YEAR)
     ELSE NULL END AS next_renewal_example
FROM subscriptions s;

-- Expired subscriptions (naive)
SELECT s.* FROM subscriptions s WHERE (s.renewal_cycle = 'monthly' AND DATE_ADD(s.start_date, INTERVAL 1 MONTH) < CURDATE()) OR (s.renewal_cycle = 'yearly' AND DATE_ADD(s.start_date, INTERVAL 1 YEAR) < CURDATE());
