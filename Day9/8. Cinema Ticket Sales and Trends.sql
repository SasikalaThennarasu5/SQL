-- ############################################################
-- 1. Hospital Patient Management Warehouse
-- ############################################################

-- OLTP Tables
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender CHAR(1),
    dob DATE
);

CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    admission_date DATE,
    discharge_date DATE,
    doctor_id INT,
    dept_id INT
);

-- Data Warehouse (Star Schema)
CREATE TABLE dim_patient (
    patient_key INT PRIMARY KEY,
    patient_id INT,
    name VARCHAR(100),
    gender CHAR(1),
    dob DATE
);

CREATE TABLE dim_doctor (
    doctor_key INT PRIMARY KEY,
    doctor_id INT,
    doctor_name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE dim_department (
    dept_key INT PRIMARY KEY,
    dept_id INT,
    dept_name VARCHAR(100)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT,
    quarter INT
);

CREATE TABLE fact_admissions (
    admission_key INT PRIMARY KEY,
    patient_key INT,
    doctor_key INT,
    dept_key INT,
    time_key INT,
    stay_duration INT
);

-- ETL Example
CREATE OR REPLACE FUNCTION calculate_stay_duration(in_date DATE, out_date DATE)
RETURNS INT AS $$
BEGIN
    RETURN DATE_PART('day', out_date - in_date);
END;
$$ LANGUAGE plpgsql;

-- OLAP Query: Average stay by department
SELECT d.dept_name, AVG(f.stay_duration) AS avg_stay
FROM fact_admissions f
JOIN dim_department d ON f.dept_key = d.dept_key
GROUP BY d.dept_name;

-- ############################################################
-- 2. Retail Sales Analytics
-- ############################################################

-- OLTP Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Star Schema
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100)
);

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id INT,
    name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT
);

CREATE TABLE fact_sales (
    sales_key INT PRIMARY KEY,
    customer_key INT,
    product_key INT,
    time_key INT,
    quantity INT,
    total DECIMAL(10,2)
);

-- OLAP: Monthly sales trend
SELECT t.month, SUM(f.total) AS total_sales
FROM fact_sales f
JOIN dim_time t ON f.time_key = t.time_key
GROUP BY t.month;

-- ############################################################
-- 3. Library Borrowing and Analytics
-- ############################################################

-- OLTP
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    joined DATE
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE borrowings (
    borrow_id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE,
    return_date DATE
);

-- Star Schema
CREATE TABLE dim_member (
    member_key INT PRIMARY KEY,
    member_id INT,
    name VARCHAR(100)
);

CREATE TABLE dim_book (
    book_key INT PRIMARY KEY,
    book_id INT,
    title VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    date DATE,
    month INT,
    year INT
);

CREATE TABLE fact_borrowing (
    borrowing_key INT PRIMARY KEY,
    member_key INT,
    book_key INT,
    time_key INT,
    duration INT
);

-- OLAP: Average borrow duration by genre
SELECT b.genre, AVG(f.duration) AS avg_duration
FROM fact_borrowing f
JOIN dim_book b ON f.book_key = b.book_key
GROUP BY b.genre;

-- ############################################################
-- 4. University Student Performance Warehouse
-- ############################################################

-- OLTP
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    batch INT
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100)
);

CREATE TABLE exams (
    exam_id INT PRIMARY KEY,
    subject_id INT,
    exam_date DATE,
    semester INT
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    exam_id INT,
    score VARCHAR(10)
);

-- Star Schema
CREATE TABLE dim_student (
    student_key INT PRIMARY KEY,
    student_id INT,
    name VARCHAR(100),
    department VARCHAR(100),
    batch INT
);

CREATE TABLE dim_subject (
    subject_key INT PRIMARY KEY,
    subject_id INT,
    subject_name VARCHAR(100)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    exam_date DATE,
    semester INT,
    year INT
);

CREATE TABLE fact_scores (
    score_key INT PRIMARY KEY,
    student_key INT,
    subject_key INT,
    time_key INT,
    numeric_score INT
);

-- Example: ETL convert letter grades
CREATE OR REPLACE FUNCTION convert_score(score TEXT)
RETURNS INT AS $$
BEGIN
    RETURN CASE
        WHEN score = 'A' THEN 90
        WHEN score = 'B' THEN 80
        WHEN score = 'C' THEN 70
        WHEN score = 'D' THEN 60
        ELSE 50
    END;
END;
$$ LANGUAGE plpgsql;

-- OLAP: Failure rate by subject
SELECT s.subject_name, 
       COUNT(*) FILTER (WHERE f.numeric_score < 50) * 100.0 / COUNT(*) AS failure_rate
FROM fact_scores f
JOIN dim_subject s ON f.subject_key = s.subject_key
GROUP BY s.subject_name;

-- ############################################################
-- 5. Online Food Delivery Reporting System
-- ############################################################

-- OLTP
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    location_id INT
);

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_time TIMESTAMP,
    delivery_time TIMESTAMP,
    total_cost DECIMAL(10,2),
    category VARCHAR(50)
);

-- Snowflake DW
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100),
    location_key INT
);

CREATE TABLE dim_location (
    location_key INT PRIMARY KEY,
    location_id INT,
    city VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    order_time TIMESTAMP,
    hour INT,
    day INT,
    month INT,
    year INT
);

CREATE TABLE fact_delivery (
    delivery_key INT PRIMARY KEY,
    customer_key INT,
    restaurant_id INT,
    time_key INT,
    duration_mins INT,
    cost DECIMAL(10,2),
    category VARCHAR(50)
);

-- ETL: Calculate delivery duration
CREATE OR REPLACE FUNCTION calc_delivery_mins(start TIMESTAMP, end_time TIMESTAMP)
RETURNS INT AS $$
BEGIN
    RETURN EXTRACT(EPOCH FROM end_time - start) / 60;
END;
$$ LANGUAGE plpgsql;

-- OLAP: Average delivery time by region
SELECT l.region, AVG(f.duration_mins) AS avg_time
FROM fact_delivery f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_location l ON c.location_key = l.location_key
GROUP BY l.region;

-- ############################################################
-- 6. Airline Booking and Delay Insights
-- ############################################################

-- OLTP
CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    route_id INT,
    aircraft_id INT,
    scheduled_departure TIMESTAMP,
    actual_departure TIMESTAMP
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    flight_id INT,
    booking_date DATE
);

-- Star Schema
CREATE TABLE dim_route (
    route_key INT PRIMARY KEY,
    route_id INT,
    source VARCHAR(100),
    destination VARCHAR(100)
);

CREATE TABLE dim_aircraft (
    aircraft_key INT PRIMARY KEY,
    aircraft_id INT,
    model VARCHAR(100)
);

CREATE TABLE fact_flights (
    flight_key INT PRIMARY KEY,
    route_key INT,
    aircraft_key INT,
    delay_mins INT,
    flight_duration INT
);

-- ETL: delay and duration
CREATE OR REPLACE FUNCTION calc_delay(sched TIMESTAMP, actual TIMESTAMP)
RETURNS INT AS $$
BEGIN
    RETURN EXTRACT(EPOCH FROM actual - sched) / 60;
END;
$$ LANGUAGE plpgsql;

-- OLAP: Average delay by route
SELECT r.source, r.destination, AVG(f.delay_mins) AS avg_delay
FROM fact_flights f
JOIN dim_route r ON f.route_key = r.route_key
GROUP BY r.source, r.destination;

-- ############################################################
-- 7. Bank Loan Analytics Warehouse
-- ############################################################

-- OLTP
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    branch_id INT
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(50),
    status VARCHAR(50),
    amount DECIMAL(12,2)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    amount DECIMAL(10,2),
    payment_date DATE
);

-- Snowflake Schema
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100),
    branch_key INT
);

CREATE TABLE dim_branch (
    branch_key INT PRIMARY KEY,
    branch_id INT,
    name VARCHAR(100)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT
);

CREATE TABLE fact_loans (
    loan_key INT PRIMARY KEY,
    customer_key INT,
    loan_type VARCHAR(50),
    status VARCHAR(50),
    amount DECIMAL(12,2),
    payment_total DECIMAL(12,2)
);

-- OLAP: Default rate by branch
SELECT b.name AS branch, 
       COUNT(*) FILTER (WHERE f.status = 'default') * 100.0 / COUNT(*) AS default_rate
FROM fact_loans f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_branch b ON c.branch_key = b.branch_key
GROUP BY b.name;

-- ############################################################
-- 8. Cinema Ticket Sales and Trends
-- ############################################################

-- OLTP
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE shows (
    show_id INT PRIMARY KEY,
    movie_id INT,
    show_time TIMESTAMP,
    theater_id INT
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    show_id INT,
    seat_count INT,
    price DECIMAL(10,2)
);

-- Star Schema
CREATE TABLE dim_movie (
    movie_key INT PRIMARY KEY,
    movie_id INT,
    title VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    show_time TIMESTAMP,
    day INT,
    month INT,
    year INT
);

CREATE TABLE fact_bookings (
    booking_key INT PRIMARY KEY,
    customer_key INT,
    movie_key INT,
    time_key INT,
    seat_count INT,
    revenue DECIMAL(10,2)
);

-- OLAP: Occupancy rate by movie
SELECT m.title, SUM(f.seat_count) AS total_seats, SUM(f.revenue) AS revenue
FROM fact_bookings f
JOIN dim_movie m ON f.movie_key = m.movie_key
GROUP BY m.title;

-- Genre-based trend
SELECT m.genre, t.month, COUNT(*) AS bookings
FROM fact_bookings f
JOIN dim_movie m ON f.movie_key = m.movie_key
JOIN dim_time t ON f.time_key = t.time_key
GROUP BY m.genre, t.month
ORDER BY t.month;

-- ############################################################
-- END OF FILE
-- ############################################################
