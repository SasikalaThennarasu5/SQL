-- Music Album Tracker

-- Jazz or Classical albums released after 2015
SELECT title, artist, price FROM albums WHERE genre IN ('Jazz', 'Classical') AND release_year > 2015;

-- List all artists
SELECT DISTINCT artist FROM albums;

-- Titles containing 'Love'
SELECT * FROM albums WHERE title LIKE '%Love%';

-- Albums with NULL price
SELECT * FROM albums WHERE price IS NULL;

-- Sort by release_year DESC, title ASC
SELECT * FROM albums ORDER BY release_year DESC, title ASC;
