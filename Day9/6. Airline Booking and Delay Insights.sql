-- ========================================
-- AIRLINE BOOKING AND DELAY INSIGHTS DW
-- ========================================

-- ---------------------
-- 1. OLTP SCHEMA
-- ---------------------
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20),
    route_id INT,
    aircraft_id INT,
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    actual_departure_time TIMESTAMP,
    actual_arrival_time TIMESTAMP,
    carrier VARCHAR(50)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    flight_id INT,
    booking_time TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- ---------------------
-- 2. WAREHOUSE: STAR SCHEMA
-- ---------------------

CREATE TABLE dim_route (
    route_id INT PRIMARY KEY,
    origin VARCHAR(50),
    destination VARCHAR(50)
);

CREATE TABLE dim_aircraft (
    aircraft_id INT PRIMARY KEY,
    model VARCHAR(50),
    capacity INT
);

CREATE TABLE dim_time (
    time_id SERIAL PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(15)
);

CREATE TABLE fact_flights (
    flight_id INT PRIMARY KEY,
    route_id INT,
    aircraft_id INT,
    time_id INT,
    carrier VARCHAR(50),
    delay_minutes INT,
    flight_duration_minutes INT,
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES dim_aircraft(aircraft_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- ---------------------
-- 3. ETL PROCESS (SIMULATED)
-- ---------------------

-- Step 1: Load dimension tables

INSERT INTO dim_route (route_id, origin, destination)
SELECT DISTINCT route_id, 'CityA', 'CityB'
FROM flights;

INSERT INTO dim_aircraft (aircraft_id, model, capacity)
SELECT DISTINCT aircraft_id, 'Airbus A320', 180
FROM flights;

INSERT INTO dim_time (full_date, day, month, year, weekday)
SELECT DISTINCT
    DATE(f.departure_time),
    EXTRACT(DAY FROM f.departure_time),
    EXTRACT(MONTH FROM f.departure_time),
    EXTRACT(YEAR FROM f.departure_time),
    TO_CHAR(f.departure_time, 'Day')
FROM flights f;

-- Step 2: Transform & load fact table

INSERT INTO fact_flights (flight_id, route_id, aircraft_id, time_id, carrier, delay_minutes, flight_duration_minutes)
SELECT
    f.flight_id,
    f.route_id,
    f.aircraft_id,
    dt.time_id,
    f.carrier,
    EXTRACT(EPOCH FROM (f.actual_departure_time - f.departure_time)) / 60 AS delay_minutes,
    EXTRACT(EPOCH FROM (f.actual_arrival_time - f.actual_departure_time)) / 60 AS flight_duration_minutes
FROM flights f
JOIN dim_time dt ON DATE(f.departure_time) = dt.full_date;

-- ---------------------
-- 4. OLAP REPORTS
-- ---------------------

-- A. Average delay by route
SELECT
    dr.origin, dr.destination,
    ROUND(AVG(ff.delay_minutes), 2) AS avg_delay
FROM fact_flights ff
JOIN dim_route dr ON ff.route_id = dr.route_id
GROUP BY dr.origin, dr.destination
ORDER BY avg_delay DESC;

-- B. Carrier ranking by average delay
SELECT
    carrier,
    ROUND(AVG(delay_minutes), 2) AS avg_delay
FROM fact_flights
GROUP BY carrier
ORDER BY avg_delay;

-- C. Drill-down: Delays by weekday
SELECT
    dt.weekday,
    ROUND(AVG(ff.delay_minutes), 2) AS avg_delay
FROM fact_flights ff
JOIN dim_time dt ON ff.time_id = dt.time_id
GROUP BY dt.weekday
ORDER BY avg_delay DESC;

-- D. Roll-up: Monthly delay trends
SELECT
    dt.month,
    dt.year,
    ROUND(AVG(ff.delay_minutes), 2) AS avg_delay
FROM fact_flights ff
JOIN dim_time dt ON ff.time_id = dt.time_id
GROUP BY dt.year, dt.month
ORDER BY dt.year, dt.month;

-- ---------------------
-- 5. OLTP vs DW Comparison
-- ---------------------

-- OLTP (Real-Time)
-- Check-in system accesses real-time flight status
SELECT
    flight_number,
    departure_time,
    actual_departure_time
FROM flights
WHERE flight_id = 101;

-- DW (Analytics)
-- Insights on delays by aircraft
SELECT
    da.model,
    ROUND(AVG(ff.delay_minutes), 2) AS avg_delay
FROM fact_flights ff
JOIN dim_aircraft da ON ff.aircraft_id = da.aircraft_id
GROUP BY da.model
ORDER BY avg_delay DESC;
