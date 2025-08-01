-- Create Tables
CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    guest_name VARCHAR(100),
    phone_number VARCHAR(15)
);

CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10),
    room_type VARCHAR(50),
    price_per_night DECIMAL(10, 2)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

-- Calculate total stay cost per guest
SELECT g.guest_name,
       SUM(DATEDIFF(b.check_out, b.check_in) * r.price_per_night) AS total_cost
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN rooms r ON b.room_id = r.room_id
GROUP BY g.guest_name;

-- Available rooms (not booked during a specific period)
SELECT *
FROM rooms r
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.room_id = r.room_id
      AND '2025-08-10' < b.check_out
      AND '2025-08-15' > b.check_in
);

-- Guests who stayed more than 5 nights in total
SELECT g.guest_name,
       SUM(DATEDIFF(b.check_out, b.check_in)) AS total_nights
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_name
HAVING SUM(DATEDIFF(b.check_out, b.check_in)) > 5;

-- Total revenue by room type
SELECT r.room_type,
       SUM(DATEDIFF(b.check_out, b.check_in) * r.price_per_night) AS revenue
FROM rooms r
JOIN bookings b ON r.room_id = b.room_id
GROUP BY r.room_type;

-- JOIN: Guest booking details
SELECT g.guest_name, r.room_number, b.check_in, b.check_out
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id;

-- LEFT JOIN: Guests with no bookings
SELECT g.guest_name, b.booking_id
FROM guests g
LEFT JOIN bookings b ON g.guest_id = b.guest_id
WHERE b.booking_id IS NULL;
