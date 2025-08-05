 13. Event Management and Ticketing
CREATE TABLE events (
    event_id INT PRIMARY KEY,
    title VARCHAR(100) UNIQUE,
    event_date DATE
);

CREATE TABLE attendees (
    attendee_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT CHECK (age >= 18)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    event_id INT,
    attendee_id INT,
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id)
);

-- Update event date
UPDATE events SET event_date = event_date + INTERVAL '7 days' WHERE event_id = 1;

-- Delete expired events
DELETE FROM tickets WHERE event_id IN (SELECT event_id FROM events WHERE event_date < CURRENT_DATE);
DELETE FROM events WHERE event_date < CURRENT_DATE;

-- Modify UNIQUE constraint
ALTER TABLE events DROP CONSTRAINT events_title_key;
ALTER TABLE events ADD CONSTRAINT events_title_key UNIQUE(title);

-- Transaction: bulk register
BEGIN;
INSERT INTO attendees VALUES (10, 'John Doe', 25);
INSERT INTO tickets VALUES (10, 1, 10);
-- If duplicate found
ROLLBACK;