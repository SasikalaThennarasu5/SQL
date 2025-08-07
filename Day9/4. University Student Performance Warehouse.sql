-- 1. OLTP Tables

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    batch_year INT
);

CREATE TABLE subjects (
    subject_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50)
);

CREATE TABLE exams (
    exam_id SERIAL PRIMARY KEY,
    subject_id INT REFERENCES subjects(subject_id),
    exam_date DATE,
    semester VARCHAR(10)
);

CREATE TABLE grades (
    grade_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    exam_id INT REFERENCES exams(exam_id),
    raw_score VARCHAR(10) -- Inconsistent (e.g., 'A+', '85', 'B', '70%')
);

-- 2. Star Schema

-- Dimension: Student
CREATE TABLE dim_student (
    student_key SERIAL PRIMARY KEY,
    student_id INT,
    name VARCHAR(100),
    department VARCHAR(50),
    batch_year INT
);

-- Dimension: Subject
CREATE TABLE dim_subject (
    subject_key SERIAL PRIMARY KEY,
    subject_id INT,
    name VARCHAR(100),
    department VARCHAR(50)
);

-- Dimension: Time
CREATE TABLE dim_time (
    time_key SERIAL PRIMARY KEY,
    exam_date DATE,
    year INT,
    month INT,
    semester VARCHAR(10)
);

-- Fact Table: Scores
CREATE TABLE fact_scores (
    score_id SERIAL PRIMARY KEY,
    student_key INT REFERENCES dim_student(student_key),
    subject_key INT REFERENCES dim_subject(subject_key),
    time_key INT REFERENCES dim_time(time_key),
    numeric_score DECIMAL(5,2),
    pass BOOLEAN
);

-- 3. ETL Transform: Grading Format Normalization

-- Example ETL function to convert grades to numeric
CREATE OR REPLACE FUNCTION normalize_grade(raw VARCHAR)
RETURNS DECIMAL AS $$
BEGIN
    CASE 
        WHEN raw ILIKE 'A+' THEN RETURN 95;
        WHEN raw ILIKE 'A' THEN RETURN 90;
        WHEN raw ILIKE 'B+' THEN RETURN 85;
        WHEN raw ILIKE 'B' THEN RETURN 80;
        WHEN raw ~ '^[0-9]+%' THEN RETURN REPLACE(raw, '%', '')::DECIMAL;
        WHEN raw ~ '^[0-9]+$' THEN RETURN raw::DECIMAL;
        ELSE RETURN NULL;
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Example insert into warehouse (ETL script simulation)
-- (Normally done in batches or via procedure)

-- 4. OLAP Reports

-- (a) Average score by semester
SELECT 
    dt.semester,
    AVG(fs.numeric_score) AS avg_score
FROM fact_scores fs
JOIN dim_time dt ON fs.time_key = dt.time_key
GROUP BY dt.semester;

-- (b) Subject-wise failure rate
SELECT 
    ds.name AS subject,
    COUNT(*) FILTER (WHERE fs.pass = FALSE)::DECIMAL / COUNT(*) * 100 AS failure_rate_percentage
FROM fact_scores fs
JOIN dim_subject ds ON fs.subject_key = ds.subject_key
GROUP BY ds.name;

-- (c) Slice/Dice: Department vs Batch Avg Score
SELECT 
    ds.department,
    ds.batch_year,
    AVG(fs.numeric_score) AS avg_score
FROM fact_scores fs
JOIN dim_student ds ON fs.student_key = ds.student_key
GROUP BY ds.department, ds.batch_year;

-- 5. Comparison

-- OLTP Granular View
SELECT s.name, sub.name AS subject, e.exam_date, g.raw_score
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN exams e ON g.exam_id = e.exam_id
JOIN subjects sub ON e.subject_id = sub.subject_id;

-- OLAP Summary View
SELECT ds.name AS subject, AVG(fs.numeric_score) AS avg_score
FROM fact_scores fs
JOIN dim_subject ds ON fs.subject_key = ds.subject_key
GROUP BY ds.name;
