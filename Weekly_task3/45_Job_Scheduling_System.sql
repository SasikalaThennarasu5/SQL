-- Job Scheduling System
CREATE TABLE jobs (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    frequency VARCHAR(100)
);

CREATE TABLE job_logs (
    id INT PRIMARY KEY,
    job_id INT,
    run_time DATETIME,
    status VARCHAR(50)
);

-- Last run per job
SELECT j.id, j.name, MAX(l.run_time) AS last_run
FROM jobs j
LEFT JOIN job_logs l ON j.id = l.job_id
GROUP BY j.id, j.name;

-- Status counts by job
SELECT job_id, status, COUNT(*) AS status_count
FROM job_logs
GROUP BY job_id, status;
