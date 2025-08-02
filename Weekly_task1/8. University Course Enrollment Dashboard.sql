-- 1. Schema Creation
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(100),
    code VARCHAR(10),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade DECIMAL(5,2),
    status VARCHAR(20), -- 'completed', 'dropped', etc.
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 2. Sample Data

-- Departments
INSERT INTO departments VALUES
(1, 'Computer Science'),
(2, 'Mathematics'),
(3, 'Business');

-- Students
INSERT INTO students VALUES
(1, 'Alice', 1),
(2, 'Bob', 1),
(3, 'Charlie', 2),
(4, 'Diana', 3),
(5, 'Eve', 1);

-- Courses
INSERT INTO courses VALUES
(101, 'Intro to Python', 'CS101', 1),
(102, 'Advanced SQL', 'CS102', 1),
(201, 'Linear Algebra', 'MATH201', 2),
(301, 'Business Ethics', 'BUS301', 3);

-- Enrollments
INSERT INTO enrollments VALUES
(1, 1, 101, 85, 'completed'),
(2, 1, 102, 78, 'completed'),
(3, 2, 101, 62, 'completed'),
(4, 3, 201, NULL, 'dropped'),
(5, 4, 301, 90, 'completed'),
(6, 5, 101, 88, 'completed'),
(7, 5, 102, NULL, 'dropped');

-- 3. Queries

-- a. Get enrollment count per course
SELECT 
  c.title,
  COUNT(e.enrollment_id) AS total_enrolled
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.title;

-- b. Find courses with highest dropout count using subquery in FROM
SELECT 
  course_title,
  dropout_count
FROM (
    SELECT 
      c.title AS course_title,
      COUNT(*) AS dropout_count
    FROM enrollments e
    JOIN courses c ON e.course_id = c.course_id
    WHERE e.status = 'dropped'
    GROUP BY c.title
) AS dropout_summary
ORDER BY dropout_count DESC;

-- c. Find students not enrolled in any course using LEFT JOIN
SELECT s.student_id, s.name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;

-- d. Map pass/fail grade using CASE
SELECT 
  s.name,
  c.title,
  e.grade,
  CASE 
    WHEN e.grade >= 50 THEN 'Pass'
    WHEN e.grade IS NULL THEN 'N/A'
    ELSE 'Fail'
  END AS result
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- e. Filter courses by list of codes using IN
SELECT * FROM courses
WHERE code IN ('CS101', 'CS102');

-- f. Find students who completed both Python and SQL using INTERSECT
SELECT s.name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.title = 'Intro to Python' AND e.status = 'completed'

INTERSECT

SELECT s.name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.title = 'Advanced SQL' AND e.status = 'completed';
