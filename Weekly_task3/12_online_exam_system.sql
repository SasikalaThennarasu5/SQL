-- Task 12: Online Exam System

CREATE TABLE exams (
    id INT PRIMARY KEY,
    course_id INT,
    date DATE
);

CREATE TABLE questions (
    id INT PRIMARY KEY,
    exam_id INT,
    text TEXT,
    correct_option CHAR(1)
);

CREATE TABLE student_answers (
    student_id INT,
    question_id INT,
    selected_option CHAR(1)
);

-- Sample Data
INSERT INTO exams VALUES (1, 101, '2025-02-01');
INSERT INTO questions VALUES (1, 1, 'What is 2+2?', 'B');
INSERT INTO student_answers VALUES (1, 1, 'B'), (2, 1, 'A');

-- Calculate scores
SELECT sa.student_id,
       SUM(CASE WHEN sa.selected_option = q.correct_option THEN 1 ELSE 0 END) AS score
FROM student_answers sa
JOIN questions q ON sa.question_id = q.id
GROUP BY sa.student_id;