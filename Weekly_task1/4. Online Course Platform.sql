-- 1. Create Tables
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY,
    enrollment_id INT,
    score DECIMAL(5,2),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- 2. Insert Sample Data
INSERT INTO students VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie'), (4, 'Diana');

INSERT INTO courses VALUES 
(101, 'ReactJS'), 
(102, 'NodeJS'), 
(103, 'SQL Basics'), 
(104, 'Data Structures');

INSERT INTO enrollments VALUES 
(1, 1, 101),
(2, 2, 101),
(3, 1, 102),
(4, 3, 103),
(5, 4, 104),
(6, 2, 104);

INSERT INTO grades VALUES 
(1, 1, 88.5),
(2, 2, 77.0),
(3, 3, 91.0),
(4, 4, 85.5),
(5, 5, 65.0),
(6, 6, 72.5);

-- 3. SELECT Students Enrolled in ReactJS
SELECT s.name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_name = 'ReactJS';

-- 4. INNER JOIN to Show Scores
SELECT s.name, c.course_name, g.score
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id;

-- 5. CASE to Categorize Grades
SELECT s.name, c.course_name, g.score,
  CASE 
    WHEN g.score >= 85 THEN 'A'
    WHEN g.score >= 70 THEN 'B'
    ELSE 'C'
  END AS grade_category
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id;

-- 6. Average Marks per Course
SELECT c.course_name, AVG(g.score) AS avg_score
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY c.course_name;

-- 7. Courses with > 50 Students
SELECT c.course_name, COUNT(*) AS student_count
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name
HAVING COUNT(*) > 50;

-- 8. Students in Specific Courses (IN)
SELECT name FROM students
WHERE student_id IN (
  SELECT student_id FROM enrollments
  WHERE course_id IN (101, 102)
);

-- 9. Top Student per Course (Correlated Subquery)
SELECT s.name, c.course_name, g.score
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
WHERE g.score = (
  SELECT MAX(g2.score)
  FROM enrollments e2
  JOIN grades g2 ON e2.enrollment_id = g2.enrollment_id
  WHERE e2.course_id = e.course_id
);
