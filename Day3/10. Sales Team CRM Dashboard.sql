-- Create Tables
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT
);

CREATE TABLE registrations (
    registration_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Students registered for a specific course
SELECT s.student_name
FROM registrations r
JOIN students s ON r.student_id = s.student_id
WHERE r.course_id = 201;

-- Total students per course
SELECT c.course_name, COUNT(r.student_id) AS total_students
FROM courses c
JOIN registrations r ON c.course_id = r.course_id
GROUP BY c.course_name;

-- Students not registered in any course
SELECT s.student_name
FROM students s
LEFT JOIN registrations r ON s.student_id = r.student_id
WHERE r.student_id IS NULL;

-- Courses with more than 3 credits
SELECT * FROM courses
WHERE credits > 3;

-- Courses registered by a specific student
SELECT s.student_name, c.course_name, r.semester
FROM registrations r
JOIN students s ON r.student_id = s.student_id
JOIN courses c ON r.course_id = c.course_id
WHERE s.student_id = 1001;

-- Number of courses per semester
SELECT semester, COUNT(DISTINCT course_id) AS total_courses
FROM registrations
GROUP BY semester;
