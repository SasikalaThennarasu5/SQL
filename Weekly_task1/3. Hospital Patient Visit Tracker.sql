-- 1. Create Tables

CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE doctors (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE patients (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE
);

CREATE TABLE appointments (
    id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    type VARCHAR(20) CHECK (type IN ('routine', 'emergency')),
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

-- 2. Insert Sample Data

INSERT INTO departments (id, name) VALUES
(1, 'Cardiology'), (2, 'Neurology'), (3, 'Pediatrics');

INSERT INTO doctors (id, name, department_id) VALUES
(1, 'Dr. Smith', 1),
(2, 'Dr. Jones', 2),
(3, 'Dr. Patel', 3);

INSERT INTO patients (id, name, dob) VALUES
(1, 'Alice', '1980-05-12'),
(2, 'Bob', '1992-07-08'),
(3, 'Charlie', '1975-03-23'),
(4, 'Daisy', '2000-11-01');

INSERT INTO appointments (id, patient_id, doctor_id, appointment_date, type) VALUES
(1, 1, 1, '2025-07-01', 'routine'),
(2, 2, 2, '2025-07-03', 'emergency'),
(3, 1, 1, '2025-07-05', 'routine'),
(4, 3, 3, '2025-07-10', 'emergency'),
(5, 3, 3, '2025-07-12', 'routine');

-- 3. LEFT JOIN: Show all patients even those without appointments

SELECT p.id AS patient_id, p.name AS patient_name, a.appointment_date, a.type
FROM patients p
LEFT JOIN appointments a ON p.id = a.patient_id;

-- 4. Filter appointments in a date range using BETWEEN

SELECT * 
FROM appointments 
WHERE appointment_date BETWEEN '2025-07-01' AND '2025-07-10';

-- 5. Aggregate visit counts per department

SELECT d.name AS department, COUNT(a.id) AS total_visits
FROM appointments a
JOIN doctors doc ON a.doctor_id = doc.id
JOIN departments d ON doc.department_id = d.id
GROUP BY d.name;

-- 6. FULL OUTER JOIN: Show all appointments and doctors, even if missing

SELECT 
    a.id AS appointment_id,
    a.appointment_date,
    d.name AS doctor_name
FROM appointments a
FULL OUTER JOIN doctors d ON a.doctor_id = d.id;

-- 7. Subquery in FROM: Daily appointment summary

SELECT 
    daily_summary.appointment_date,
    daily_summary.total_appointments
FROM (
    SELECT appointment_date, COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY appointment_date
) AS daily_summary;

-- 8. Use CASE to flag emergency vs. routine

SELECT 
    a.id AS appointment_id,
    p.name AS patient_name,
    a.appointment_date,
    CASE 
        WHEN a.type = 'emergency' THEN 'Emergency Visit'
        ELSE 'Routine Visit'
    END AS visit_type
FROM appointments a
JOIN patients p ON a.patient_id = p.id;

-- 9. UNION: Combine regular and emergency visits

SELECT p.name AS patient, a.appointment_date, 'Routine' AS visit_type
FROM appointments a
JOIN patients p ON a.patient_id = p.id
WHERE a.type = 'routine'

UNION

SELECT p.name AS patient, a.appointment_date, 'Emergency' AS visit_type
FROM appointments a
JOIN patients p ON a.patient_id = p.id
WHERE a.type = 'emergency';
