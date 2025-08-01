-- Create Tables
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    goal VARCHAR(100)
);

CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(100)
);

CREATE TABLE workouts (
    workout_id INT PRIMARY KEY,
    user_id INT,
    trainer_id INT,
    workout_type VARCHAR(50),
    calories_burned INT,
    session_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

CREATE TABLE goals (
    goal_id INT PRIMARY KEY,
    user_id INT,
    goal_description VARCHAR(200),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Average calories burned per workout
SELECT workout_type, AVG(calories_burned) AS avg_calories
FROM workouts
GROUP BY workout_type;

-- Users with more than 10 sessions
SELECT u.user_name, COUNT(w.workout_id) AS session_count
FROM users u
JOIN workouts w ON u.user_id = w.user_id
GROUP BY u.user_name
HAVING COUNT(w.workout_id) > 10;

-- INNER JOIN users and workouts
SELECT u.user_name, w.workout_type, w.calories_burned
FROM users u
INNER JOIN workouts w ON u.user_id = w.user_id;

-- LEFT JOIN trainers and users (via workouts)
SELECT t.trainer_name, u.user_name
FROM trainers t
LEFT JOIN workouts w ON t.trainer_id = w.trainer_id
LEFT JOIN users u ON w.user_id = u.user_id;

-- SELF JOIN: users with same fitness goals
SELECT u1.user_name AS user1, u2.user_name AS user2, u1.goal
FROM users u1
JOIN users u2 ON u1.goal = u2.goal
    AND u1.user_id <> u2.user_id;
