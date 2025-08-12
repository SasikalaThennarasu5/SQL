-- Complaint Management System
CREATE TABLE complaints (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    department_id INT,
    status VARCHAR(50)
);

CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE responses (
    complaint_id INT,
    responder_id INT,
    message TEXT
);

-- Status summary
SELECT status, COUNT(*) AS count_by_status FROM complaints GROUP BY status;

-- Department workload
SELECT d.name, COUNT(c.id) AS complaints_count FROM departments d LEFT JOIN complaints c ON d.id = c.department_id GROUP BY d.name;
