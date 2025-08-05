11. Flight Booking and Passenger Management
CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_date DATE CHECK (flight_date >= CURRENT_DATE),
    status VARCHAR(20),
    available_seats INT
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    passenger_id INT,
    flight_id INT,
    seat_no INT,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    ticket_id INT,
    amount DECIMAL(10, 2),
    status VARCHAR(20),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);

-- Update flight seat count
UPDATE flights SET available_seats = available_seats - 1 WHERE flight_id = 1;

-- Delete unpaid tickets
DELETE FROM tickets WHERE ticket_id NOT IN (SELECT ticket_id FROM payments WHERE status = 'paid');

-- Drop and recreate NOT NULL
ALTER TABLE tickets ALTER COLUMN seat_no DROP NOT NULL;
ALTER TABLE tickets ALTER COLUMN seat_no SET NOT NULL;

-- Transaction
BEGIN;
INSERT INTO tickets VALUES (1, 1, 1, 10);
INSERT INTO payments VALUES (1, 1, 5000.00, 'failed');
ROLLBACK;
