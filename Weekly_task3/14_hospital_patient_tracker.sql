-- Task 14: Hospital Patient Tracker

CREATE TABLE patients (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE
);

CREATE TABLE doctors (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE visits (
    id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_time DATETIME,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

-- Sample Data
INSERT INTO patients VALUES (1, 'Tom Hanks', '1980-05-14'), (2, 'Emma Stone', '1990-02-12');
INSERT INTO doctors VALUES (1, 'Dr. Adams', 'Cardiology'), (2, 'Dr. Lee', 'Neurology');
INSERT INTO visits VALUES (1, 1, 1, '2025-04-01 10:00:00');

-- Query patients by doctor
SELECT d.name AS doctor, p.name AS patient, v.visit_time
FROM visits v
JOIN doctors d ON v.doctor_id = d.id
JOIN patients p ON v.patient_id = p.id
WHERE d.name = 'Dr. Adams';