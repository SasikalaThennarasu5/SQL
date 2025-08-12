-- Task 27: Notification System

CREATE TABLE notifications (
    id INT PRIMARY KEY,
    user_id INT,
    message TEXT,
    status VARCHAR(10),
    created_at DATETIME
);

-- Sample Data
INSERT INTO notifications VALUES (1, 1, 'Welcome!', 'unread', '2025-08-01 09:00:00');

-- Unread count
SELECT user_id, COUNT(*) AS unread_count
FROM notifications
WHERE status = 'unread'
GROUP BY user_id;