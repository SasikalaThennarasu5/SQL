-- Create Tables
CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    model VARCHAR(100),
    car_type VARCHAR(50)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    vehicle_id INT,
    customer_id INT,
    rental_date DATE,
    return_date DATE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    rental_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-- Total rentals per vehicle
SELECT v.model, COUNT(r.rental_id) AS total_rentals
FROM vehicles v
JOIN rentals r ON v.vehicle_id = r.vehicle_id
GROUP BY v.model;

-- Vehicles rented more than 10 times
SELECT v.model, COUNT(r.rental_id) AS total_rentals
FROM vehicles v
JOIN rentals r ON v.vehicle_id = r.vehicle_id
GROUP BY v.model
HAVING COUNT(r.rental_id) > 10;

-- Average rental cost per car type
SELECT v.car_type, AVG(p.amount) AS avg_rental_cost
FROM vehicles v
JOIN rentals r ON v.vehicle_id = r.vehicle_id
JOIN payments p ON r.rental_id = p.rental_id
GROUP BY v.car_type;

-- INNER JOIN rentals and vehicles
SELECT r.rental_id, v.model, r.rental_date, r.return_date
FROM rentals r
INNER JOIN vehicles v ON r.vehicle_id = v.vehicle_id;

-- LEFT JOIN vehicles and payments (via rentals)
SELECT v.model, p.amount, p.payment_date
FROM vehicles v
LEFT JOIN rentals r ON v.vehicle_id = r.vehicle_id
LEFT JOIN payments p ON r.rental_id = p.rental_id;

-- SELF JOIN on cars of same model and type
SELECT v1.model AS car1, v2.model AS car2, v1.car_type
FROM vehicles v1
JOIN vehicles v2 ON v1.car_type = v2.car_type 
    AND v1.model = v2.model 
    AND v1.vehicle_id <> v2.vehicle_id;
