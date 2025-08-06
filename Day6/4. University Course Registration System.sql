-- 4.1 Tables in 3NF
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    department_id INT,
    faculty_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    dob DATE,
    email VARCHAR(100)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 4.2 Indexes
CREATE INDEX idx_student_id ON enrollments(student_id);
CREATE INDEX idx_course_id ON enrollments(course_id);
CREATE INDEX idx_faculty_id ON courses(faculty_id);

-- 4.3 EXPLAIN: Student performance report JOINs
EXPLAIN
SELECT s.name, c.title, f.name AS faculty
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN faculty f ON c.faculty_id = f.faculty_id;

-- 4.4 Subquery: Students in more than 3 courses
SELECT s.name, COUNT(e.course_id) AS total_courses
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id
HAVING total_courses > 3;

-- 4.5 Denormalized student performance summary
CREATE TABLE student_performance_summary (
    student_id INT,
    student_name VARCHAR(100),
    total_courses INT,
    department_count INT
);

INSERT INTO student_performance_summary
SELECT 
    s.student_id,
    s.name,
    COUNT(e.course_id) AS total_courses,
    COUNT(DISTINCT c.department_id) AS department_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
GROUP BY s.student_id, s.name;

-- 4.6 Pagination: Paginated course list
SELECT * FROM courses ORDER BY title ASC LIMIT 0, 10; -- Page 1
