-- Vehicle Rental System
CREATE TABLE vehicles (
    id INT PRIMARY KEY,
    type VARCHAR(100),
    plate_number VARCHAR(50)
);

CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE rentals (
    id INT PRIMARY KEY,
    vehicle_id INT,
    customer_id INT,
    start_date DATE,
    end_date DATE
);

-- Duration and estimated charge (example rate 100 per day)
SELECT r.id, DATEDIFF(r.end_date, r.start_date) + 1 AS days_rented,
 (DATEDIFF(r.end_date, r.start_date) + 1) * 100 AS estimated_charge
FROM rentals r;

-- Vehicle availability in a date range (example range)
SELECT v.*
FROM vehicles v
LEFT JOIN rentals r ON v.id = r.vehicle_id AND NOT (r.end_date < '2025-08-01' OR r.start_date > '2025-08-31')
WHERE r.id IS NULL;
