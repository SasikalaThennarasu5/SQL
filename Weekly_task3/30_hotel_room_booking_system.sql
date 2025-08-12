-- Task 30: Hotel Room Booking System

CREATE TABLE rooms (
    id INT PRIMARY KEY,
    number VARCHAR(10),
    type VARCHAR(50)
);

CREATE TABLE guests (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE bookings (
    id INT PRIMARY KEY,
    room_id INT,
    guest_id INT,
    from_date DATE,
    to_date DATE
);

-- Sample Data
INSERT INTO rooms VALUES (1, '101', 'Deluxe');
INSERT INTO guests VALUES (1, 'John Doe');
INSERT INTO bookings VALUES (1, 1, 1, '2025-08-05', '2025-08-10');

-- Room availability
SELECT r.number, 
       CASE 
           WHEN EXISTS (
               SELECT 1 FROM bookings b 
               WHERE b.room_id = r.id 
               AND b.from_date <= '2025-08-07' 
               AND b.to_date >= '2025-08-07'
           ) THEN 'Booked'
           ELSE 'Available'
       END AS status
FROM rooms r;