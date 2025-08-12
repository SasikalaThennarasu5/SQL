-- Task 28: Course Progress Tracker

CREATE TABLE courses (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE lessons (
    id INT PRIMARY KEY,
    course_id INT,
    title VARCHAR(100)
);

CREATE TABLE progress (
    student_id INT,
    lesson_id INT,
    completed_at DATE
);

-- Sample Data
INSERT INTO courses VALUES (1, 'SQL Basics');
INSERT INTO lessons VALUES (1, 1, 'Intro'), (2, 1, 'SELECT Queries');
INSERT INTO progress VALUES (1, 1, '2025-08-01');

-- Completion percentage
SELECT p.student_id, (COUNT(p.lesson_id) * 100.0 / (SELECT COUNT(*) FROM lessons WHERE course_id = 1)) AS completion_percentage
FROM progress p
JOIN lessons l ON p.lesson_id = l.id
WHERE l.course_id = 1
GROUP BY p.student_id;