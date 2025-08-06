-- 5.1 3NF Normalized Schema
CREATE TABLE room_types (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50),
    price_per_night DECIMAL(10,2)
);

CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10),
    room_type_id INT,
    FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id)
);

CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- 5.2 Indexes
CREATE INDEX idx_room_type ON rooms(room_type_id);
CREATE INDEX idx_check_in ON bookings(check_in);
CREATE INDEX idx_guest_id ON bookings(guest_id);

-- 5.3 EXPLAIN booking history query
EXPLAIN
SELECT g.name, b.check_in, b.check_out, r.room_number
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
WHERE g.name LIKE '%John%';

-- 5.4 Optimized JOIN across 3+ tables
SELECT g.name, r.room_number, rt.type_name, p.amount
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
JOIN room_types rt ON r.room_type_id = rt.room_type_id
JOIN payments p ON b.booking_id = p.booking_id;

-- 5.5 Denormalized Daily Revenue Report Table
CREATE TABLE daily_revenue_report (
    report_date DATE,
    total_revenue DECIMAL(10,2)
);

INSERT INTO daily_revenue_report
SELECT payment_date, SUM(amount)
FROM payments
GROUP BY payment_date;

-- 5.6 LIMIT: Top 10 highest-paying guests
SELECT g.name, SUM(p.amount) AS total_spent
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN guests g ON b.guest_id = g.guest_id
GROUP BY g.guest_id
ORDER BY total_spent DESC
LIMIT 10;

