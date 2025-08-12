-- Task 11: Course Enrollment System

CREATE TABLE courses (
    id INT PRIMARY KEY,
    title VARCHAR(100),
    instructor VARCHAR(100)
);

CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE enrollments (
    course_id INT,
    student_id INT,
    enroll_date DATE,
    PRIMARY KEY (course_id, student_id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- Sample Data
INSERT INTO courses VALUES (1, 'Math 101', 'Dr. Smith'), (2, 'Physics 101', 'Dr. Johnson');
INSERT INTO students VALUES (1, 'Alice', 'alice@example.com'), (2, 'Bob', 'bob@example.com');
INSERT INTO enrollments VALUES (1, 1, '2025-01-10'), (2, 2, '2025-01-15');

-- Query: Students per course
SELECT c.title, COUNT(e.student_id) AS total_students
FROM courses c
JOIN enrollments e ON c.id = e.course_id
GROUP BY c.title;