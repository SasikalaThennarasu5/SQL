-- Task 21: Blog Management System

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE posts (
    id INT PRIMARY KEY,
    user_id INT,
    title VARCHAR(200),
    content TEXT,
    published_date DATE
);

CREATE TABLE comments (
    id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment_text TEXT,
    commented_at DATETIME
);

-- Sample Data
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
INSERT INTO posts VALUES (1, 1, 'First Post', 'Content here', '2025-08-01');
INSERT INTO comments VALUES (1, 1, 2, 'Nice post!', '2025-08-02 10:00:00');

-- Get comments with post details
SELECT p.title, u.name, c.comment_text
FROM comments c
JOIN posts p ON c.post_id = p.id
JOIN users u ON c.user_id = u.id;