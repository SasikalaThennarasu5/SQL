-- Freelance Project Management
CREATE TABLE freelancers (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    skill VARCHAR(255)
);

CREATE TABLE projects (
    id INT PRIMARY KEY,
    client_name VARCHAR(255),
    title VARCHAR(255)
);

CREATE TABLE proposals (
    freelancer_id INT,
    project_id INT,
    bid_amount DECIMAL(10,2),
    status VARCHAR(50)
);

-- Accepted proposals
SELECT p.project_id, pr.title, p.freelancer_id, p.bid_amount
FROM proposals p
JOIN projects pr ON p.project_id = pr.id
WHERE p.status = 'accepted';

-- Count accepted projects per freelancer
SELECT freelancer_id, COUNT(DISTINCT project_id) AS projects_count
FROM proposals
WHERE status = 'accepted'
GROUP BY freelancer_id;
