-- Task 29: Recruitment Portal

CREATE TABLE jobs (
    id INT PRIMARY KEY,
    title VARCHAR(100),
    company VARCHAR(100)
);

CREATE TABLE candidates (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE applications (
    job_id INT,
    candidate_id INT,
    status VARCHAR(50),
    applied_at DATE
);

-- Sample Data
INSERT INTO jobs VALUES (1, 'Developer', 'TechCorp');
INSERT INTO candidates VALUES (1, 'Alice');
INSERT INTO applications VALUES (1, 1, 'Pending', '2025-08-01');

-- Job-wise applicant count
SELECT j.title, COUNT(a.candidate_id) AS applicant_count
FROM applications a
JOIN jobs j ON a.job_id = j.id
GROUP BY j.title;