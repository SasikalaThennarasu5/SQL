-- Tables
CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE doctors (
  doctor_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  specialization VARCHAR(100),
  department_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
  patient_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  age INT CHECK (age BETWEEN 0 AND 120)
);

CREATE TABLE appointments (
  appointment_id INT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  date DATE,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Insert with NOT NULL
INSERT INTO patients (patient_id, name, age) VALUES (1, 'John Doe', 35);

-- Update doctor specialization
UPDATE doctors SET specialization = 'Cardiology', department_id = 2 WHERE doctor_id = 1;

-- Transaction with SAVEPOINT and ROLLBACK
BEGIN;
SAVEPOINT before_delete;
DELETE FROM patients WHERE patient_id = 1;
-- If error
ROLLBACK TO before_delete;
COMMIT;

-- Atomic transaction
BEGIN;
UPDATE doctors SET specialization = 'Neuro' WHERE doctor_id = 2;
UPDATE appointments SET date = '2025-08-10' WHERE doctor_id = 2;
COMMIT;
