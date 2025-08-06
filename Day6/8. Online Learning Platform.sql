-- 8.1 3NF Tables
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    bio TEXT
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    instructor_id INT,
    category VARCHAR(100),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    course_id INT,
    enroll_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE completions (
    completion_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    course_id INT,
    completion_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 8.2 Indexes
CREATE INDEX idx_course_id ON completions(course_id);
CREATE INDEX idx_user_id ON completions(user_id);
CREATE INDEX idx_completion_date ON completions(completion_date);

-- 8.3 EXPLAIN for course completion report
EXPLAIN
SELECT c.title, i.name AS instructor, COUNT(cm.user_id) AS total_completions
FROM courses c
JOIN instructors i ON c.instructor_id = i.instructor_id
JOIN completions cm ON c.course_id = cm.course_id
GROUP BY c.course_id;

-- 8.4 Subquery: Users who completed more than 3 courses
SELECT u.name, COUNT(c.completion_id) AS completed_courses
FROM users u
JOIN completions c ON u.user_id = c.user_id
GROUP BY u.user_id
HAVING completed_courses > 3;

-- 8.5 Denormalized leaderboard table
CREATE TABLE course_completion_leaderboard (
    user_id INT,
    user_name VARCHAR(100),
    total_courses_completed INT
);

INSERT INTO course_completion_leaderboard
SELECT 
    u.user_id,
    u.name,
    COUNT(c.completion_id)
FROM users u
JOIN completions c ON u.user_id = c.user_id
GROUP BY u.user_id, u.name;

-- 8.6 LIMIT: Top 5 trending courses (by completions)
SELECT c.title, COUNT(cm.user_id) AS completion_count
FROM courses c
JOIN completions cm ON c.course_id = cm.course_id
GROUP BY c.course_id
ORDER BY completion_count DESC
LIMIT 5;
