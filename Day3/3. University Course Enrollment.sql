-- Create tables
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    major VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    department VARCHAR(100)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Number of students enrolled per course
SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- Average grade per course (assuming A=4, B=3, C=2, D=1, F=0)
SELECT course_id,
       AVG(
           CASE grade
               WHEN 'A' THEN 4
               WHEN 'B' THEN 3
               WHEN 'C' THEN 2
               WHEN 'D' THEN 1
               WHEN 'F' THEN 0
               ELSE NULL
           END
       ) AS avg_gpa
FROM enrollments
GROUP BY course_id;

-- Students who enrolled in more than 3 courses
SELECT student_id, COUNT(course_id) AS course_count
FROM enrollments
GROUP BY student_id
HAVING COUNT(course_id) > 3;

-- Courses without any enrollments
SELECT c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.course_id IS NULL;

-- JOIN to list students with their enrolled courses
SELECT s.student_name, c.course_name, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;
