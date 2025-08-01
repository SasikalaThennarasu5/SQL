-- Flight Schedule System

-- Flights to Chennai or Mumbai
SELECT flight_number, origin, destination FROM flights WHERE destination IN ('Chennai', 'Mumbai');

-- Flights ending with 'AI'
SELECT * FROM flights WHERE flight_number LIKE '%AI';

-- Departure times within a day (example: '2025-08-01')
SELECT * FROM flights WHERE departure_time BETWEEN '2025-08-01 00:00:00' AND '2025-08-01 23:59:59';

-- Flights with NULL status
SELECT * FROM flights WHERE status IS NULL;

-- Unique destinations
SELECT DISTINCT destination FROM flights;

-- Sort by departure_time ASC
SELECT * FROM flights ORDER BY departure_time ASC;
