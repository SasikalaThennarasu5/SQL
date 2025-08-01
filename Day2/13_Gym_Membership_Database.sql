-- Gym Membership Database

-- Active members aged between 20 and 40
SELECT name, age, plan_type FROM members WHERE status = 'active' AND age BETWEEN 20 AND 40;

-- List all plan types
SELECT DISTINCT plan_type FROM members;

-- Names starting with 'S'
SELECT * FROM members WHERE name LIKE 'S%';

-- Members with NULL status
SELECT * FROM members WHERE status IS NULL;

-- Sort by age ASC, name ASC
SELECT * FROM members ORDER BY age ASC, name ASC;
