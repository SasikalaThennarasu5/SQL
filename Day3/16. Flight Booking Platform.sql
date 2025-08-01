-- Create Tables
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY,
    airline_name VARCHAR(100)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    airline_id INT,
    route VARCHAR(100),
    capacity INT,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    seats_booked INT,
    booking_date DATE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

-- Total bookings per airline
SELECT a.airline_name, COUNT(b.booking_id) AS total_bookings
FROM airlines a
JOIN flights f ON a.airline_id = f.airline_id
JOIN bookings b ON f.flight_id = b.flight_id
GROUP BY a.airline_name;

-- Most frequent flyers
SELECT p.passenger_name, COUNT(b.booking_id) AS flights_taken
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_name
ORDER BY flights_taken DESC;

-- Flights with average occupancy > 80%
SELECT f.flight_id, f.route,
       AVG(b.seats_booked * 1.0 / f.capacity) * 100 AS avg_occupancy_percent
FROM flights f
JOIN bookings b ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.route
HAVING AVG(b.seats_booked * 1.0 / f.capacity) > 0.8;

-- INNER JOIN: bookings ↔ flights ↔ passengers
SELECT b.booking_id, p.passenger_name, f.route
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
JOIN passengers p ON b.passenger_id = p.passenger_id;

-- RIGHT JOIN: airlines ↔ flights
SELECT a.airline_name, f.route
FROM airlines a
RIGHT JOIN flights f ON a.airline_id = f.airline_id;

-- SELF JOIN: passengers who flew the same routes
SELECT p1.passenger_name AS passenger1, p2.passenger_name AS passenger2, f1.route
FROM bookings b1
JOIN flights f1 ON b1.flight_id = f1.flight_id
JOIN passengers p1 ON b1.passenger_id = p1.passenger_id
JOIN bookings b2 ON f1.route = (SELECT route FROM flights WHERE flight_id = b2.flight_id)
JOIN passengers p2 ON b2.passenger_id = p2.passenger_id
WHERE p1.passenger_id <> p2.passenger_id;
