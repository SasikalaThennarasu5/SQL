-- Movie Rental System

-- Available Action or Thriller movies
SELECT title, genre, rating FROM movies WHERE available = 1 AND genre IN ('Action', 'Thriller');

-- Titles containing 'Star'
SELECT * FROM movies WHERE title LIKE '%Star%';

-- Movies with NULL ratings
SELECT * FROM movies WHERE rating IS NULL;

-- List all genres
SELECT DISTINCT genre FROM movies;

-- Sort by rating DESC, price ASC
SELECT * FROM movies ORDER BY rating DESC, price ASC;
