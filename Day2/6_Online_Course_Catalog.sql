-- Online Course Catalog

-- Active courses under ₹1000
SELECT title, category, price FROM courses WHERE status = 'active' AND price < 1000;

-- List all instructors
SELECT DISTINCT instructor FROM courses;

-- Courses starting with 'Data'
SELECT * FROM courses WHERE title LIKE 'Data%';

-- Filter by category IN ('Tech', 'Business')
SELECT * FROM courses WHERE category IN ('Tech', 'Business');

-- Courses with NULL instructor
SELECT * FROM courses WHERE instructor IS NULL;

-- Sort by price DESC, duration ASC
SELECT * FROM courses ORDER BY price DESC, duration ASC;
