-- Event Management System
CREATE TABLE events (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    max_capacity INT
);

CREATE TABLE attendees (
    event_id INT,
    user_id INT,
    registered_at DATETIME
);

-- Event-wise participant count
SELECT e.id, e.title, COUNT(a.user_id) AS participant_count FROM events e LEFT JOIN attendees a ON e.id = a.event_id GROUP BY e.id, e.title;

-- Capacity alerts
SELECT e.id, e.title, e.max_capacity, COUNT(a.user_id) AS participant_count FROM events e LEFT JOIN attendees a ON e.id = a.event_id GROUP BY e.id, e.title, e.max_capacity HAVING participant_count >= e.max_capacity;
