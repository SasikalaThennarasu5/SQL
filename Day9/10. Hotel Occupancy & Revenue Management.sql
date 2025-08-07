-- ==============================
-- HOTEL OCCUPANCY & REVENUE MANAGEMENT
-- ==============================

-- 1. OLTP TABLES
CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_type VARCHAR(50),
    rate_per_night DECIMAL(10,2),
    max_occupancy INT
);

CREATE TABLE services (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT REFERENCES guests(guest_id),
    room_id INT REFERENCES rooms(room_id),
    check_in DATE,
    check_out DATE,
    booking_date DATE,
    total_amount DECIMAL(10,2)
);

CREATE TABLE booking_services (
    booking_id INT REFERENCES bookings(booking_id),
    service_id INT REFERENCES services(service_id),
    quantity INT
);

-- ==============================
-- 2. DATA WAREHOUSE (Snowflake Schema)
-- ==============================

-- Dimension: dim_guest
CREATE TABLE dim_guest (
    guest_key INT PRIMARY KEY,
    guest_id INT,
    full_name VARCHAR(100)
);

-- Dimension: dim_room
CREATE TABLE dim_room (
    room_key INT PRIMARY KEY,
    room_id INT,
    room_type VARCHAR(50),
    rate_per_night DECIMAL(10,2)
);

-- Dimension: dim_date
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT,
    season VARCHAR(20)
);

-- Fact: fact_booking
CREATE TABLE fact_booking (
    booking_key INT PRIMARY KEY,
    booking_id INT,
    guest_key INT,
    room_key INT,
    date_key INT,
    stay_duration INT,
    total_amount DECIMAL(10,2),
    revenue_from_services DECIMAL(10,2)
);

-- ==============================
-- 3. ETL EXTRACT + TRANSFORM + LOAD
-- ==============================

-- Example: ETL for dim_date
INSERT INTO dim_date (date_key, full_date, day, month, year, quarter, season)
SELECT 
    ROW_NUMBER() OVER (ORDER BY d)::INT AS date_key,
    d,
    EXTRACT(DAY FROM d),
    EXTRACT(MONTH FROM d),
    EXTRACT(YEAR FROM d),
    EXTRACT(QUARTER FROM d),
    CASE 
        WHEN EXTRACT(MONTH FROM d) IN (12,1,2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM d) IN (3,4,5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM d) IN (6,7,8) THEN 'Summer'
        ELSE 'Fall'
    END
FROM generate_series('2023-01-01'::DATE, '2025-12-31'::DATE, INTERVAL '1 day') d;

-- Transform: Stay Duration & Revenue
-- Populate fact_booking
INSERT INTO fact_booking (
    booking_key, booking_id, guest_key, room_key, date_key, stay_duration, total_amount, revenue_from_services
)
SELECT
    b.booking_id AS booking_key,
    b.booking_id,
    g.guest_id AS guest_key,
    r.room_id AS room_key,
    dd.date_key,
    (b.check_out - b.check_in) AS stay_duration,
    b.total_amount,
    COALESCE(SUM(bs.quantity * s.price), 0)
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
JOIN dim_date dd ON dd.full_date = b.booking_date
LEFT JOIN booking_services bs ON bs.booking_id = b.booking_id
LEFT JOIN services s ON s.service_id = bs.service_id
GROUP BY b.booking_id, g.guest_id, r.room_id, dd.date_key, b.check_in, b.check_out, b.total_amount;

-- ==============================
-- 4. REPORTING QUERIES
-- ==============================

-- a) Occupancy by Season
SELECT 
    dd.season,
    COUNT(DISTINCT fb.booking_id) AS total_bookings,
    SUM(fb.stay_duration) AS total_nights
FROM fact_booking fb
JOIN dim_date dd ON fb.date_key = dd.date_key
GROUP BY dd.season
ORDER BY total_nights DESC;

-- b) Profitability by Room Type
SELECT 
    dr.room_type,
    COUNT(*) AS num_bookings,
    SUM(fb.total_amount + fb.revenue_from_services) AS total_revenue,
    AVG(fb.total_amount + fb.revenue_from_services) AS avg_revenue_per_booking
FROM fact_booking fb
JOIN dim_room dr ON fb.room_key = dr.room_id
GROUP BY dr.room_type
ORDER BY total_revenue DESC;

-- ==============================
-- 5. OLAP SUPPORT FOR PRICING DECISIONS
-- ==============================

-- OLAP Cube-like Aggregation
SELECT
    dd.year,
    dd.season,
    dr.room_type,
    COUNT(*) AS bookings,
    SUM(fb.total_amount) AS room_revenue,
    SUM(fb.revenue_from_services) AS service_revenue,
    SUM(fb.total_amount + fb.revenue_from_services) AS total_revenue
FROM fact_booking fb
JOIN dim_date dd ON fb.date_key = dd.date_key
JOIN dim_room dr ON fb.room_key = dr.room_id
GROUP BY ROLLUP (dd.year, dd.season, dr.room_type)
ORDER BY dd.year, dd.season, dr.room_type;

-- Pricing decision support: Average revenue by room type and season
SELECT
    dr.room_type,
    dd.season,
    AVG(fb.total_amount + fb.revenue_from_services) AS avg_total_revenue
FROM fact_booking fb
JOIN dim_room dr ON fb.room_key = dr.room_id
JOIN dim_date dd ON fb.date_key = dd.date_key
GROUP BY dr.room_type, dd.season
ORDER BY dr.room_type, dd.season;
