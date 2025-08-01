-- Vehicle Service Records

-- Serviced in last 30 days
SELECT vehicle_no, service_type, cost FROM services WHERE service_date BETWEEN DATE('now', '-30 days') AND DATE('now');

-- Vehicles ending with '9'
SELECT * FROM services WHERE vehicle_no LIKE '%9';

-- Cost between 500 and 2000
SELECT * FROM services WHERE cost BETWEEN 500 AND 2000;

-- NULL technician
SELECT * FROM services WHERE technician IS NULL;

-- List service types
SELECT DISTINCT service_type FROM services;

-- Sort by service_date DESC, cost ASC
SELECT * FROM services ORDER BY service_date DESC, cost ASC;
