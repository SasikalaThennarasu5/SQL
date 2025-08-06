-- 3.1 Tables in 3NF
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    dob DATE,
    gender VARCHAR(10)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME,
    reason TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    medication_name VARCHAR(100),
    prescribed_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- 3.2 Indexing
CREATE INDEX idx_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_patient_id ON appointments(patient_id);
CREATE INDEX idx_doctor_id ON appointments(doctor_id);

-- 3.3 Execution plan for frequent appointment lookups
EXPLAIN SELECT * FROM appointments WHERE doctor_id = 2 AND appointment_date BETWEEN '2025-08-01' AND '2025-08-31';

-- 3.4 Subquery: Patients with most visits
SELECT p.name, COUNT(*) AS total_visits
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id
HAVING total_visits = (
  SELECT MAX(visit_count) FROM (
    SELECT COUNT(*) AS visit_count
    FROM appointments
    GROUP BY patient_id
  ) AS sub
);

-- 3.5 Denormalized view for dashboard
CREATE VIEW patient_dashboard AS
SELECT 
  p.patient_id,
  p.name,
  COUNT(DISTINCT a.appointment_id) AS total_appointments,
  COUNT(DISTINCT m.medication_id) AS total_medications
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN medications m ON p.patient_id = m.patient_id
GROUP BY p.patient_id, p.name;

-- 3.6 LIMIT: Last 5 appointments for a patient
SELECT * 
FROM appointments 
WHERE patient_id = 1
ORDER BY appointment_date DESC
LIMIT 5;
