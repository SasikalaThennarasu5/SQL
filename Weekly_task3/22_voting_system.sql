-- Task 22: Voting System

CREATE TABLE polls (
    id INT PRIMARY KEY,
    question VARCHAR(255)
);

CREATE TABLE options (
    id INT PRIMARY KEY,
    poll_id INT,
    option_text VARCHAR(255)
);

CREATE TABLE votes (
    user_id INT,
    option_id INT,
    voted_at DATETIME
);

-- Sample Data
INSERT INTO polls VALUES (1, 'Best Programming Language?');
INSERT INTO options VALUES (1, 1, 'Python'), (2, 1, 'JavaScript');
INSERT INTO votes VALUES (1, 1, '2025-08-01 09:00:00'), (2, 2, '2025-08-01 09:05:00');

-- Count votes
SELECT o.option_text, COUNT(v.user_id) AS vote_count
FROM options o
LEFT JOIN votes v ON o.id = v.option_id
GROUP BY o.option_text;