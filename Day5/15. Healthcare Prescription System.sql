15. Healthcare Prescription System
CREATE TABLE doctors (
  doctor_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  specialization VARCHAR(100)
);
CREATE TABLE patients (
  patient_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  age INT
);
CREATE TABLE medications (
  medication_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  stock INT,
  dosage INT CHECK (dosage BETWEEN 1 AND 5)
);
CREATE TABLE prescriptions (
  prescription_id SERIAL PRIMARY KEY,
  doctor_id INT,
  patient_id INT,
  medication_id INT,
  dosage INT,
  date_prescribed DATE DEFAULT CURRENT_DATE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (medication_id) REFERENCES medications(medication_id)
);

INSERT INTO prescriptions (doctor_id, patient_id, medication_id, dosage)
VALUES (1, 2, 3, 2);
UPDATE medications SET stock = stock - 1 WHERE medication_id = 3;
DELETE FROM prescriptions
  WHERE date_prescribed < CURRENT_DATE - INTERVAL '6 months';

ALTER TABLE medications ALTER COLUMN dosage DROP NOT NULL;
ALTER TABLE medications ALTER COLUMN dosage SET NOT NULL;

BEGIN;
  INSERT INTO prescriptions (doctor_id, patient_id, medication_id, dosage)
    VALUES (1, 2, 3, 2);
  UPDATE medications SET stock = stock - 1 WHERE medication_id = 3;
COMMIT;