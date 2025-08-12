-- Task 23: Messaging System

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE conversations (
    id INT PRIMARY KEY
);

CREATE TABLE messages (
    id INT PRIMARY KEY,
    conversation_id INT,
    sender_id INT,
    message_text TEXT,
    sent_at DATETIME
);

-- Sample Data
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
INSERT INTO conversations VALUES (1);
INSERT INTO messages VALUES (1, 1, 1, 'Hello Bob', '2025-08-01 10:00:00');

-- Recent messages
SELECT c.id, m.message_text, m.sent_at
FROM messages m
JOIN conversations c ON m.conversation_id = c.id
WHERE c.id = 1
ORDER BY m.sent_at DESC;