-- Tables
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE courses (
  course_id INT PRIMARY KEY,
  title VARCHAR(100),
  availability INT
);

CREATE TABLE enrollments (
  enrollment_id INT PRIMARY KEY,
  student_id INT,
  course_id INT,
  grade INT CHECK (grade BETWEEN 0 AND 100),
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Transaction
BEGIN;
INSERT INTO enrollments (enrollment_id, student_id, course_id, grade) VALUES (1, 101, 201, 85);
UPDATE courses SET availability = availability - 1 WHERE course_id = 201;
COMMIT;
