-- 9.1 3NF Tables
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    genre_id INT,
    release_year INT,
    duration_minutes INT,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    start_date DATE,
    end_date DATE,
    plan_type VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE watch_history (
    watch_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    movie_id INT,
    watch_date DATE,
    watch_duration INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- 9.2 Indexes
CREATE INDEX idx_movie_id ON watch_history(movie_id);
CREATE INDEX idx_user_id ON watch_history(user_id);
CREATE INDEX idx_watch_date ON watch_history(watch_date);

-- 9.3 EXPLAIN: Total watch time for a user
EXPLAIN
SELECT SUM(watch_duration) AS total_watch_time
FROM watch_history
WHERE user_id = 5;

-- 9.4 Subquery: Users watching the most movies in a week
SELECT u.name, COUNT(*) AS total_views
FROM users u
JOIN watch_history w ON u.user_id = w.user_id
WHERE w.watch_date BETWEEN '2025-08-01' AND '2025-08-07'
GROUP BY u.user_id
HAVING total_views = (
  SELECT MAX(view_count) FROM (
    SELECT user_id, COUNT(*) AS view_count
    FROM watch_history
    WHERE watch_date BETWEEN '2025-08-01' AND '2025-08-07'
    GROUP BY user_id
  ) AS sub
);

-- 9.5 Denormalized monthly user engagement report
CREATE TABLE monthly_user_engagement (
    year_month VARCHAR(7),
    user_id INT,
    total_movies_watched INT,
    total_watch_time INT
);

INSERT INTO monthly_user_engagement
SELECT 
  DATE_FORMAT(watch_date, '%Y-%m') AS year_month,
  user_id,
  COUNT(*) AS movies_watched,
  SUM(watch_duration) AS total_watch_time
FROM watch_history
GROUP BY year_month, user_id;

-- 9.6 LIMIT: Top 10 most-watched movies
SELECT m.title, COUNT(*) AS view_count
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
GROUP BY w.movie_id
ORDER BY view_count DESC
LIMIT 10;
