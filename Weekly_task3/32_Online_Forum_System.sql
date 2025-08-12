-- Online Forum System
CREATE TABLE threads (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    user_id INT
);

CREATE TABLE posts (
    id INT PRIMARY KEY,
    thread_id INT,
    user_id INT,
    content TEXT,
    parent_post_id INT,
    posted_at DATETIME
);

-- Self join for reply chains
SELECT p1.id AS post_id, p2.id AS reply_id, p2.content AS reply_content
FROM posts p1
JOIN posts p2 ON p1.id = p2.parent_post_id;

-- Thread view aggregation
SELECT t.title, COUNT(p.id) AS total_posts
FROM threads t
JOIN posts p ON t.id = p.thread_id
GROUP BY t.title;
