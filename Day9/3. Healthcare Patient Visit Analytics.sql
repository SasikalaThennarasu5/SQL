-- 1. OLTP Tables
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender CHAR(1)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    department_id INT,
    scheduled_time DATETIME,
    checkin_time DATETIME,
    checkout_time DATETIME,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 2. Star Schema for Data Warehouse
-- Dimensions
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    day_of_week VARCHAR(10),
    month INT,
    quarter INT,
    year INT
);

CREATE TABLE dim_doctor (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    gender CHAR(1),
    dob DATE
);

-- Fact Table
CREATE TABLE fact_visits (
    visit_id INT PRIMARY KEY,
    time_id INT,
    doctor_id INT,
    patient_id INT,
    department_id INT,
    wait_time_mins INT,
    duration_mins INT,
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctor(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id)
);

-- 3. ETL Logic (Simplified)
-- a. Populate dim_time
INSERT INTO dim_time (time_id, date, day_of_week, month, quarter, year)
SELECT DISTINCT 
    ROW_NUMBER() OVER (ORDER BY scheduled_time),
    CAST(scheduled_time AS DATE),
    DATENAME(WEEKDAY, scheduled_time),
    MONTH(scheduled_time),
    DATEPART(QUARTER, scheduled_time),
    YEAR(scheduled_time)
FROM appointments;

-- b. Populate dim_doctor
INSERT INTO dim_doctor (doctor_id, doctor_name, specialization)
SELECT doctor_id, name, specialization
FROM doctors;

-- c. Populate dim_patient
INSERT INTO dim_patient (patient_id, patient_name, gender, dob)
SELECT patient_id, name, gender, dob
FROM patients;

-- d. Populate fact_visits with computed wait time and duration
INSERT INTO fact_visits (visit_id, time_id, doctor_id, patient_id, department_id, wait_time_mins, duration_mins)
SELECT 
    a.appointment_id,
    t.time_id,
    a.doctor_id,
    a.patient_id,
    a.department_id,
    DATEDIFF(MINUTE, a.scheduled_time, a.checkin_time) AS wait_time,
    DATEDIFF(MINUTE, a.checkin_time, a.checkout_time) AS duration
FROM appointments a
JOIN dim_time t ON CAST(a.scheduled_time AS DATE) = t.date;

-- 4. OLAP Reports

-- Average Wait Time Per Doctor
SELECT 
    d.doctor_name,
    AVG(f.wait_time_mins) AS avg_wait_time
FROM fact_visits f
JOIN dim_doctor d ON f.doctor_id = d.doctor_id
GROUP BY d.doctor_name;

-- Department-wise Traffic
SELECT 
    dep.name AS department_name,
    COUNT(*) AS total_visits
FROM fact_visits f
JOIN departments dep ON f.department_id = dep.department_id
GROUP BY dep.name;

-- Monthly Visit Trend
SELECT 
    t.year,
    t.month,
    COUNT(*) AS total_visits
FROM fact_visits f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.year, t.month
ORDER BY t.year, t.month;

-- 5. OLTP vs OLAP Comparison (Query Examples)

-- OLTP: Granular appointment log
SELECT * FROM appointments WHERE doctor_id = 3;

-- OLAP: Aggregated doctor performance
SELECT 
    d.specialization,
    AVG(f.duration_mins) AS avg_consult_duration
FROM fact_visits f
JOIN dim_doctor d ON f.doctor_id = d.doctor_id
GROUP BY d.specialization;
