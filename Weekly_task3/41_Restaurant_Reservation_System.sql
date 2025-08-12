-- Restaurant Reservation System
CREATE TABLE tables (
    id INT PRIMARY KEY,
    table_number INT,
    capacity INT
);

CREATE TABLE guests (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE reservations (
    id INT PRIMARY KEY,
    guest_id INT,
    table_id INT,
    date DATE,
    time_slot VARCHAR(50)
);

-- Overlap detection
SELECT r1.id AS r1_id, r2.id AS r2_id
FROM reservations r1
JOIN reservations r2 ON r1.table_id = r2.table_id AND r1.date = r2.date AND r1.time_slot = r2.time_slot AND r1.id <> r2.id;

-- Daily summary
SELECT date, COUNT(*) AS total_reservations
FROM reservations
GROUP BY date;
