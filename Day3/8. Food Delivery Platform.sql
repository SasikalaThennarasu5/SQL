-- Create Tables
CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100),
    contact_number VARCHAR(15)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20),
    origin VARCHAR(100),
    destination VARCHAR(100),
    departure_time DATETIME,
    arrival_time DATETIME
);

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY,
    passenger_id INT,
    flight_id INT,
    seat_number VARCHAR(10),
    booking_date DATE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- List all passengers on a specific flight
SELECT p.passenger_name, r.seat_number
FROM reservations r
JOIN passengers p ON r.passenger_id = p.passenger_id
WHERE r.flight_id = 101;

-- Flights with more than 100 passengers
SELECT f.flight_number, COUNT(r.passenger_id) AS passenger_count
FROM flights f
JOIN reservations r ON f.flight_id = r.flight_id
GROUP BY f.flight_number
HAVING COUNT(r.passenger_id) > 100;

-- Flights with no passengers
SELECT f.flight_number
FROM flights f
LEFT JOIN reservations r ON f.flight_id = r.flight_id
WHERE r.flight_id IS NULL;

-- Reservations made in the last 7 days
SELECT *
FROM reservations
WHERE booking_date >= CURRENT_DATE - INTERVAL '7 days';

-- INNER JOIN: Passenger flight details
SELECT p.passenger_name, f.flight_number, f.origin, f.destination, r.seat_number
FROM reservations r
JOIN passengers p ON r.passenger_id = p.passenger_id
JOIN flights f ON r.flight_id = f.flight_id;

-- LEFT JOIN: Passengers who never booked a flight
SELECT p.passenger_name
FROM passengers p
LEFT JOIN reservations r ON p.passenger_id = r.passenger_id
WHERE r.reservation_id IS NULL;
