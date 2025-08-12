-- IT Support Ticket System
CREATE TABLE tickets (
    id INT PRIMARY KEY,
    user_id INT,
    issue TEXT,
    status VARCHAR(50),
    created_at DATETIME,
    resolved_at DATETIME
);

CREATE TABLE support_staff (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE assignments (
    ticket_id INT,
    staff_id INT
);

-- Average resolution time in hours
SELECT AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)) AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL;

-- Ticket volume by status
SELECT status, COUNT(*) AS count_by_status
FROM tickets
GROUP BY status;
