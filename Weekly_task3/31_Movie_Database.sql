-- Movie Database
CREATE TABLE movies (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    release_year INT,
    genre_id INT
);

CREATE TABLE genres (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE ratings (
    user_id INT,
    movie_id INT,
    score DECIMAL(3,1)
);

-- AVG rating per movie
SELECT m.title, AVG(r.score) AS avg_rating
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.title;

-- JOIN movies with genres and ratings
SELECT m.title, g.name AS genre, AVG(r.score) AS avg_rating
FROM movies m
JOIN genres g ON m.genre_id = g.id
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.title, g.name;
