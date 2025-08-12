-- Course Feedback System
CREATE TABLE courses (
    id INT PRIMARY KEY,
    title VARCHAR(255)
);

CREATE TABLE feedback (
    id INT PRIMARY KEY,
    course_id INT,
    user_id INT,
    rating INT,
    comments TEXT
);

-- Average rating per course
SELECT c.id, c.title, AVG(f.rating) AS avg_rating
FROM courses c
LEFT JOIN feedback f ON c.id = f.course_id
GROUP BY c.id, c.title;

-- Simple sentiment keyword counts
SELECT course_id,
 SUM(CASE WHEN comments LIKE '%good%' OR comments LIKE '%excellent%' THEN 1 ELSE 0 END) AS positive_count,
 SUM(CASE WHEN comments LIKE '%bad%' OR comments LIKE '%poor%' THEN 1 ELSE 0 END) AS negative_count
FROM feedback
GROUP BY course_id;
