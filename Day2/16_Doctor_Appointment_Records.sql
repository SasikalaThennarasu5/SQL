-- Appointments within a given week (example: 2025-07-25 to 2025-07-31)
SELECT doctor_name, date, status 
FROM appointments 
WHERE date BETWEEN '2025-07-25' AND '2025-07-31';

-- Patients with 'th' in name
SELECT * FROM appointments 
WHERE patient_name LIKE '%th%';

-- Appointments with NULL notes
SELECT * FROM appointments 
WHERE notes IS NULL;

-- List of all distinct doctors
SELECT DISTINCT doctor_name 
FROM appointments;

-- Sort appointments by date descending
SELECT * FROM appointments 
ORDER BY date DESC;
