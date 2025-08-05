-- Create tables
CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    model VARCHAR(50),
    available BOOLEAN DEFAULT TRUE,
    mileage INT,
    fuel_level INT
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    vehicle_id INT,
    customer_id INT,
    rental_date DATE,
    return_date DATE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CHECK (return_date > rental_date)
);

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    rental_id INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-- Insert rental with vehicle availability check
INSERT INTO rentals (rental_id, vehicle_id, customer_id, rental_date, return_date)
SELECT 1, 101, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '2 days'
WHERE EXISTS (
    SELECT 1 FROM vehicles WHERE vehicle_id = 101 AND available = TRUE
);

-- Update vehicle status after return
UPDATE vehicles
SET mileage = mileage + 120, fuel_level = 50, available = TRUE
WHERE vehicle_id = 101;

-- Delete completed rentals older than 3 months
DELETE FROM rentals
WHERE return_date < CURRENT_DATE - INTERVAL '3 months';

-- Use SAVEPOINT and rollback on pricing error
BEGIN;
  SAVEPOINT before_invoice;
  INSERT INTO invoices (invoice_id, rental_id, amount)
  VALUES (301, 1, 1500.00);
  -- Simulating error: wrong amount
  ROLLBACK TO SAVEPOINT before_invoice;
  -- Retry with correct amount
  INSERT INTO invoices (invoice_id, rental_id, amount)
  VALUES (301, 1, 1200.00);
COMMIT;

-- Simulate durability (example only, actual durability depends on DB engine)
-- After DB crash/reconnect, committed transactions are still persisted
SELECT * FROM invoices WHERE invoice_id = 301;
