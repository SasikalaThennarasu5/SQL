-- 1. Tables Setup

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    is_required BOOLEAN, -- TRUE = Required, FALSE = Elective
    prerequisite_id INT -- Self-referencing for prerequisites
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE StudentCourses (
    student_id INT,
    course_id INT,
    completion_date DATE,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 2. Recursive CTE: Course Path (prerequisite chain)
WITH RECURSIVE CoursePath AS (
    SELECT 
        course_id,
        course_name,
        is_required,
        prerequisite_id,
        CAST(course_name AS VARCHAR(500)) AS path,
        1 AS level
    FROM Courses
    WHERE prerequisite_id IS NULL

    UNION ALL

    SELECT 
        c.course_id,
        c.course_name,
        c.is_required,
        c.prerequisite_id,
        CONCAT(cp.path, ' → ', c.course_name),
        cp.level + 1
    FROM Courses c
    JOIN CoursePath cp ON c.prerequisite_id = cp.course_id
),

-- 3. CTE: Rank courses by required status (required = higher priority)
CoursePriority AS (
    SELECT
        course_id,
        course_name,
        is_required,
        RANK() OVER (ORDER BY is_required DESC, course_name) AS priority_rank
    FROM Courses
),

-- 4. CTE: LEAD() to suggest next course in a path
CourseSequence AS (
    SELECT
        prerequisite_id,
        course_id,
        course_name,
        LEAD(course_name) OVER (PARTITION BY prerequisite_id ORDER BY course_id) AS next_course
    FROM Courses
),

-- 5. CTE: Student course progress and next recommendation
StudentProgress AS (
    SELECT 
        s.student_id,
        s.name AS student_name,
        c.course_id,
        c.course_name,
        c.is_required,
        sc.completion_date,
        LEAD(sc.completion_date) OVER (PARTITION BY s.student_id ORDER BY sc.completion_date) AS next_course_date
    FROM Students s
    JOIN StudentCourses sc ON s.student_id = sc.student_id
    JOIN Courses c ON c.course_id = sc.course_id
)

-- Final Outputs

-- A. View complete prerequisite course paths
SELECT * FROM CoursePath ORDER BY path;

-- B. Ranked list of courses by priority (Required > Elective)
SELECT * FROM CoursePriority ORDER BY priority_rank;

-- C. View suggested next course in a sequence
SELECT * FROM CourseSequence WHERE next_course IS NOT NULL ORDER BY course_name;

-- D. Student course progress with next course suggestion date
SELECT * FROM StudentProgress ORDER BY student_id, completion_date;
