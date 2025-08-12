-- Task 24: Attendance Tracker

CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE attendance (
    student_id INT,
    course_id INT,
    date DATE,
    status VARCHAR(10)
);

-- Sample Data
INSERT INTO students VALUES (1, 'John'), (2, 'Jane');
INSERT INTO courses VALUES (1, 'Math'), (2, 'Science');
INSERT INTO attendance VALUES (1, 1, '2025-08-01', 'Present');

-- Summary per student
SELECT s.name, c.name AS course, COUNT(a.status) AS days_present
FROM attendance a
JOIN students s ON a.student_id = s.id
JOIN courses c ON a.course_id = c.id
WHERE a.status = 'Present'
GROUP BY s.name, c.name;