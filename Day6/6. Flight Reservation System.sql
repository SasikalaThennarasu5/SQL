-- 6.1 3NF Normalized Schema
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_name VARCHAR(100)
);

CREATE TABLE airports (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT,
    departure_airport INT,
    arrival_airport INT,
    flight_date DATE,
    departure_time TIME,
    arrival_time TIME,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (departure_airport) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport) REFERENCES airports(airport_id)
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    passport_number VARCHAR(20)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT,
    flight_id INT,
    booking_date DATE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- 6.2 Indexes
CREATE INDEX idx_flight_date ON flights(flight_date);
CREATE INDEX idx_departure_airport ON flights(departure_airport);
CREATE INDEX idx_passenger_id ON bookings(passenger_id);

-- 6.3 EXPLAIN airport/date search
EXPLAIN
SELECT f.*, a.airline_name
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
WHERE f.flight_date = '2025-08-10' AND f.departure_airport = 3;

-- 6.4 Subquery: Passengers with most flights
SELECT p.name, COUNT(b.booking_id) AS total_flights
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_id
HAVING total_flights = (
  SELECT MAX(flight_count)
  FROM (
    SELECT COUNT(*) AS flight_count
    FROM bookings
    GROUP BY passenger_id
  ) AS sub
);

-- 6.5 Denormalized Frequent Flyer Report Table
CREATE TABLE frequent_flyer_summary (
    passenger_id INT,
    passenger_name VARCHAR(100),
    total_flights INT
);

INSERT INTO frequent_flyer_summary
SELECT 
    p.passenger_id,
    p.name,
    COUNT(b.booking_id)
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_id, p.name;

-- 6.6 LIMIT: Next 5 upcoming flights
SELECT *
FROM flights
WHERE flight_date >= CURDATE()
ORDER BY flight_date, departure_time
LIMIT 5;
