-- QR Code Entry Log System
CREATE TABLE locations (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE entry_logs (
    id INT PRIMARY KEY,
    user_id INT,
    location_id INT,
    entry_time DATETIME
);

-- Count entries per location
SELECT l.name, COUNT(*) AS entries_count
FROM entry_logs el
JOIN locations l ON el.location_id = l.id
GROUP BY l.name;

-- Filter by date/time
SELECT * FROM entry_logs WHERE entry_time BETWEEN '2025-01-01' AND '2025-12-31';
