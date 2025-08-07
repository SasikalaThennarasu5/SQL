-- =====================================
-- 9. Logistics & Fleet Utilization Reporting
-- =====================================

-- OLTP SCHEMA
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    name VARCHAR(100),
    license_no VARCHAR(50),
    phone VARCHAR(15)
);

CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    model VARCHAR(100),
    fuel_type VARCHAR(50),
    capacity INT
);

CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    origin VARCHAR(100),
    destination VARCHAR(100),
    distance_km DECIMAL(10,2)
);

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    vehicle_id INT,
    driver_id INT,
    route_id INT,
    gps_start_time DATETIME,
    gps_end_time DATETIME,
    fuel_used_liters DECIMAL(10,2),
    delivery_status VARCHAR(50),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

-- =====================================
-- DATA WAREHOUSE (STAR SCHEMA)
-- =====================================

CREATE TABLE dim_vehicle (
    vehicle_id INT PRIMARY KEY,
    model VARCHAR(100),
    fuel_type VARCHAR(50),
    capacity INT
);

CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY,
    name VARCHAR(100),
    license_no VARCHAR(50)
);

CREATE TABLE dim_route (
    route_id INT PRIMARY KEY,
    origin VARCHAR(100),
    destination VARCHAR(100),
    distance_km DECIMAL(10,2)
);

CREATE TABLE dim_date (
    date_id DATE PRIMARY KEY,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(10)
);

CREATE TABLE fact_delivery (
    delivery_id INT PRIMARY KEY,
    vehicle_id INT,
    driver_id INT,
    route_id INT,
    date_id DATE,
    duration_minutes INT,
    fuel_used_liters DECIMAL(10,2),
    delivery_status VARCHAR(50),
    FOREIGN KEY (vehicle_id) REFERENCES dim_vehicle(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- =====================================
-- ETL PROCESS (Example using INSERT SELECT)
-- =====================================

-- 1. Clean GPS timestamps and calculate duration
INSERT INTO fact_delivery (delivery_id, vehicle_id, driver_id, route_id, date_id, duration_minutes, fuel_used_liters, delivery_status)
SELECT 
    d.delivery_id,
    d.vehicle_id,
    d.driver_id,
    d.route_id,
    DATE(d.gps_start_time) AS date_id,
    TIMESTAMPDIFF(MINUTE, d.gps_start_time, d.gps_end_time) AS duration_minutes,
    d.fuel_used_liters,
    d.delivery_status
FROM deliveries d
WHERE d.gps_start_time IS NOT NULL AND d.gps_end_time IS NOT NULL;

-- 2. Populate dim_date (basic version)
INSERT INTO dim_date (date_id, day, month, year, weekday)
SELECT DISTINCT 
    DATE(gps_start_time),
    DAY(gps_start_time),
    MONTH(gps_start_time),
    YEAR(gps_start_time),
    DAYNAME(gps_start_time)
FROM deliveries;

-- =====================================
-- REPORTS
-- =====================================

-- 1. Fuel usage per trip
SELECT 
    fd.delivery_id,
    dv.model,
    dr.name AS driver,
    fd.fuel_used_liters,
    fd.duration_minutes
FROM fact_delivery fd
JOIN dim_vehicle dv ON fd.vehicle_id = dv.vehicle_id
JOIN dim_driver dr ON fd.driver_id = dr.driver_id;

-- 2. Driver performance over time
SELECT 
    dd.name AS driver,
    COUNT(fd.delivery_id) AS total_deliveries,
    AVG(fd.duration_minutes) AS avg_duration,
    SUM(fd.fuel_used_liters) AS total_fuel_used
FROM fact_delivery fd
JOIN dim_driver dd ON fd.driver_id = dd.driver_id
GROUP BY dd.name;

-- 3. OLAP: Route optimization analysis
SELECT 
    dr.origin,
    dr.destination,
    COUNT(fd.delivery_id) AS trip_count,
    AVG(fd.duration_minutes) AS avg_duration,
    AVG(fd.fuel_used_liters) AS avg_fuel
FROM fact_delivery fd
JOIN dim_route dr ON fd.route_id = dr.route_id
GROUP BY dr.origin, dr.destination
ORDER BY avg_duration ASC;

-- =====================================
-- OLTP vs OLAP USE CASE
-- =====================================

-- OLTP: Real-time delivery update
UPDATE deliveries
SET delivery_status = 'Delivered', gps_end_time = NOW()
WHERE delivery_id = 101;

-- OLAP: Historical fleet performance analytics
SELECT 
    dv.fuel_type,
    AVG(fd.fuel_used_liters) AS avg_fuel_used,
    COUNT(fd.delivery_id) AS total_deliveries
FROM fact_delivery fd
JOIN dim_vehicle dv ON fd.vehicle_id = dv.vehicle_id
GROUP BY dv.fuel_type;

