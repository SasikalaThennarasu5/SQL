-- Fitness Tracker Database
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE workouts (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(100)
);

CREATE TABLE workout_logs (
    user_id INT,
    workout_id INT,
    duration INT,
    log_date DATE
);

-- Weekly summary per user
SELECT user_id, YEARWEEK(log_date, 1) AS year_week, SUM(duration) AS total_minutes
FROM workout_logs
GROUP BY user_id, YEARWEEK(log_date, 1);

-- Join for workout details
SELECT wl.user_id, w.name AS workout_name, w.type, wl.duration, wl.log_date
FROM workout_logs wl
JOIN workouts w ON wl.workout_id = w.id;
