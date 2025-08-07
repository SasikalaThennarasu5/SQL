-- 1. Tables Setup

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    prerequisite_id INT -- Self-referencing for prerequisites
);

CREATE TABLE Exams (
    exam_id INT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    course_id INT,
    semester VARCHAR(10),
    exam_date DATE,
    marks INT,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 2. CTE: Subject-wise ranking per semester
WITH SubjectRank AS (
    SELECT
        e.subject_id,
        s.subject_name,
        e.semester,
        e.student_id,
        st.name AS student_name,
        e.marks,
        RANK() OVER (PARTITION BY e.subject_id, e.semester ORDER BY e.marks DESC) AS subject_rank
    FROM Exams e
    JOIN Students st ON st.student_id = e.student_id
    JOIN Subjects s ON s.subject_id = e.subject_id
),

-- 3. CTE: Row number to show attempt order per subject per student
ExamAttempts AS (
    SELECT
        e.exam_id,
        e.student_id,
        st.name AS student_name,
        e.subject_id,
        s.subject_name,
        e.semester,
        e.exam_date,
        e.marks,
        ROW_NUMBER() OVER (PARTITION BY e.student_id, e.subject_id ORDER BY e.exam_date) AS attempt_number
    FROM Exams e
    JOIN Students st ON st.student_id = e.student_id
    JOIN Subjects s ON s.subject_id = e.subject_id
),

-- 4. CTE: Comparing marks between semesters using LEAD and LAG
MarksComparison AS (
    SELECT
        e.student_id,
        st.name AS student_name,
        e.subject_id,
        s.subject_name,
        e.semester,
        e.exam_date,
        e.marks,
        LAG(e.marks) OVER (PARTITION BY e.student_id, e.subject_id ORDER BY e.exam_date) AS prev_marks,
        LEAD(e.marks) OVER (PARTITION BY e.student_id, e.subject_id ORDER BY e.exam_date) AS next_marks
    FROM Exams e
    JOIN Students st ON st.student_id = e.student_id
    JOIN Subjects s ON s.subject_id = e.subject_id
),

-- 5. Semester-wise subject average and total per student
SemesterSubjectPerformance AS (
    SELECT
        e.student_id,
        st.name AS student_name,
        e.semester,
        e.subject_id,
        s.subject_name,
        COUNT(*) AS exam_count,
        AVG(e.marks) AS avg_marks,
        SUM(e.marks) AS total_marks
    FROM Exams e
    JOIN Students st ON st.student_id = e.student_id
    JOIN Subjects s ON s.subject_id = e.subject_id
    GROUP BY e.student_id, st.name, e.semester, e.subject_id, s.subject_name
),

-- 6. Recursive CTE for course prerequisites
CoursePrerequisites AS (
    SELECT 
        course_id,
        course_name,
        prerequisite_id,
        CAST(course_name AS VARCHAR(MAX)) AS path
    FROM Courses
    WHERE prerequisite_id IS NULL

    UNION ALL

    SELECT 
        c.course_id,
        c.course_name,
        c.prerequisite_id,
        CAST(cp.path + ' → ' + c.course_name AS VARCHAR(MAX))
    FROM Courses c
    JOIN CoursePrerequisites cp ON c.prerequisite_id = cp.course_id
)

-- Final Outputs

-- A. Toppers per subject/semester
SELECT * FROM SubjectRank WHERE subject_rank = 1 ORDER BY subject_id, semester;

-- B. Exam attempts in order
SELECT * FROM ExamAttempts ORDER BY student_id, subject_id, attempt_number;

-- C. Compare marks over time
SELECT * FROM MarksComparison ORDER BY student_id, subject_id, exam_date;

-- D. Subject-wise semester performance
SELECT * FROM SemesterSubjectPerformance ORDER BY student_id, semester, subject_id;

-- E. Course prerequisite hierarchy
SELECT * FROM CoursePrerequisites ORDER BY path;
