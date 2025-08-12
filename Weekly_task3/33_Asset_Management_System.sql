-- Asset Management System
CREATE TABLE assets (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100)
);

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE assignments (
    asset_id INT,
    user_id INT,
    assigned_date DATE,
    returned_date DATE
);

-- Current usage (not returned)
SELECT a.name, u.name AS user_name
FROM assignments asg
JOIN assets a ON asg.asset_id = a.id
JOIN users u ON asg.user_id = u.id
WHERE asg.returned_date IS NULL;

-- Asset availability
SELECT a.name, 
CASE WHEN asg.asset_id IS NULL THEN 'Available' ELSE 'In Use' END AS status
FROM assets a
LEFT JOIN assignments asg ON a.id = asg.asset_id AND asg.returned_date IS NULL;
