-- Create Tables
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    birth_date DATE,
    city VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE treatments (
    treatment_id INT PRIMARY KEY,
    appointment_id INT,
    treatment_cost DECIMAL(10, 2),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- Total patients treated per doctor
SELECT d.doctor_name, COUNT(DISTINCT a.patient_id) AS total_patients
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_name;

-- Average treatment cost per doctor
SELECT d.doctor_name, AVG(t.treatment_cost) AS avg_cost
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY d.doctor_name;

-- Doctors who treated more than 10 patients
SELECT d.doctor_name, COUNT(DISTINCT a.patient_id) AS total_patients
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_name
HAVING COUNT(DISTINCT a.patient_id) > 10;

-- INNER JOIN: Appointments with doctor details
SELECT a.appointment_id, a.appointment_date, d.doctor_name
FROM appointments a
INNER JOIN doctors d ON a.doctor_id = d.doctor_id;

-- RIGHT JOIN: All doctors including those with no appointments
SELECT d.doctor_name, a.appointment_date
FROM doctors d
RIGHT JOIN appointments a ON d.doctor_id = a.doctor_id;

-- SELF JOIN on patients to find patients with same birth date
SELECT p1.patient_name AS Patient1, p2.patient_name AS Patient2, p1.birth_date
FROM patients p1
JOIN patients p2 ON p1.birth_date = p2.birth_date AND p1.patient_id < p2.patient_id;
