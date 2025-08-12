-- Task 15: Health Records System

CREATE TABLE prescriptions (
    id INT PRIMARY KEY,
    patient_id INT,
    date DATE
);

CREATE TABLE medications (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE prescription_details (
    prescription_id INT,
    medication_id INT,
    dosage VARCHAR(50)
);

-- Sample Data
INSERT INTO prescriptions VALUES (1, 1, '2025-05-01');
INSERT INTO medications VALUES (1, 'Paracetamol'), (2, 'Amoxicillin');
INSERT INTO prescription_details VALUES (1, 1, '500mg'), (1, 2, '250mg');

-- Join to list patient prescriptions
SELECT p.id, m.name, pd.dosage
FROM prescription_details pd
JOIN medications m ON pd.medication_id = m.id
JOIN prescriptions p ON pd.prescription_id = p.id;