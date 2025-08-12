-- Survey Collection System
CREATE TABLE surveys (
    id INT PRIMARY KEY,
    title VARCHAR(255)
);

CREATE TABLE questions (
    id INT PRIMARY KEY,
    survey_id INT,
    question_text TEXT
);

CREATE TABLE responses (
    user_id INT,
    question_id INT,
    answer_text TEXT
);

-- Count and group by answers per question
SELECT q.id, q.question_text, COUNT(r.user_id) AS response_count
FROM questions q
LEFT JOIN responses r ON q.id = r.question_id
GROUP BY q.id, q.question_text;

-- Pivot-style summary (answer distribution per question)
SELECT question_id, answer_text, COUNT(*) AS cnt
FROM responses
GROUP BY question_id, answer_text;
