-- Customer Feedback Management

-- Feedback with rating >= 4 for 'Smartphone'
SELECT customer_name, rating, comment FROM feedback WHERE rating >= 4 AND product = 'Smartphone';

-- Comments with 'slow'
SELECT * FROM feedback WHERE comment LIKE '%slow%';

-- Feedback in last 30 days (example: using CURRENT_DATE)
SELECT * FROM feedback WHERE submitted_date BETWEEN DATE('now', '-30 days') AND DATE('now');

-- NULL comments
SELECT * FROM feedback WHERE comment IS NULL;

-- List reviewed products
SELECT DISTINCT product FROM feedback;

-- Sort by rating DESC, submitted_date DESC
SELECT * FROM feedback ORDER BY rating DESC, submitted_date DESC;
