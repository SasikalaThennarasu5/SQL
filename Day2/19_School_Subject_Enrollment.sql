-- Students with grade >= 80 in Math or English
SELECT * FROM subject_enrollments 
WHERE grade >= 80 AND subject IN ('Math', 'English');

-- Search student names containing 'a'
SELECT * FROM subject_enrollments 
WHERE student_name LIKE '%a%';

-- Students with NULL status
SELECT * FROM subject_enrollments 
WHERE status IS NULL;

-- List of all unique subjects
SELECT DISTINCT subject 
FROM subject_enrollments;

-- Sort enrollments by grade descending
SELECT * FROM subject_enrollments 
ORDER BY grade DESC;
