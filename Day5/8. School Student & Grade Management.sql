-- Create Tables
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    grade INT CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Insert sample data
INSERT INTO students VALUES (1, 'Alice'), (2, 'Bob');
INSERT INTO subjects VALUES (101, 'Math'), (102, 'Science');

-- Insert grades
INSERT INTO grades VALUES (1, 1, 101, 85);
INSERT INTO grades VALUES (2, 1, 102, 90);
INSERT INTO grades VALUES (3, 2, 101, 45);

-- Update grade on retest
UPDATE grades SET grade = 88 WHERE grade_id = 3;

-- Delete failing grades on withdrawal
DELETE FROM grades WHERE student_id = 2 AND grade < 50;
DELETE FROM students WHERE student_id = 2;

-- Modify constraint to expand grade scale (0-150)
-- Step 1: Drop the old constraint (syntax may vary by DBMS)
ALTER TABLE grades DROP CONSTRAINT grades_grade_check;

-- Step 2: Add new constraint
ALTER TABLE grades ADD CONSTRAINT grades_grade_check CHECK (grade BETWEEN 0 AND 150);

-- Use transaction to insert/update grades in batch
BEGIN;

-- Insert a new grade
INSERT INTO grades VALUES (4, 1, 101, 95);

-- Update an existing grade
UPDATE grades SET grade = 75 WHERE grade_id = 2;

-- Intentional error to test rollback
-- INSERT INTO grades VALUES (4, 1, 101, 999); -- Invalid grade if constraint not updated

-- If no error, commit
COMMIT;

-- If error occurs:
-- ROLLBACK;
