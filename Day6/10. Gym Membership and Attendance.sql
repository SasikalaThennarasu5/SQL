-- 10.1 3NF Tables
CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50),
    duration_months INT,
    price DECIMAL(10,2)
);

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(15),
    plan_id INT,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    trainer_id INT,
    session_date DATE,
    session_type VARCHAR(50),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- 10.2 Indexes
CREATE INDEX idx_session_date ON sessions(session_date);
CREATE INDEX idx_member_id ON sessions(member_id);
CREATE INDEX idx_trainer_id ON sessions(trainer_id);

-- 10.3 EXPLAIN: Trainer performance report
EXPLAIN
SELECT t.name, COUNT(s.session_id) AS total_sessions
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id;

-- 10.4 Subquery: Members with highest attendance
SELECT m.name, COUNT(*) AS total_attendance
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id
HAVING total_attendance = (
  SELECT MAX(session_count) FROM (
    SELECT member_id, COUNT(*) AS session_count
    FROM sessions
    GROUP BY member_id
  ) AS sub
);

-- 10.5 Denormalized trainer-wise session summary
CREATE TABLE trainer_session_summary (
    trainer_id INT,
    trainer_name VARCHAR(100),
    total_sessions INT
);

INSERT INTO trainer_session_summary
SELECT 
  t.trainer_id,
  t.name,
  COUNT(s.session_id)
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id, t.name;

-- 10.6 LIMIT: Top 5 most consistent members
SELECT m.name, COUNT(*) AS session_count
FROM sessions s
JOIN members m ON s.member_id = m.member_id
GROUP BY m.member_id
ORDER BY session_count DESC
LIMIT 5;
