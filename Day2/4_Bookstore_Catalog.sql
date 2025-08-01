-- Bookstore Catalog

-- Fiction books under 500
SELECT title, author, price FROM books WHERE genre = 'Fiction' AND price < 500;

-- List all genres
SELECT DISTINCT genre FROM books;

-- Titles starting with 'The'
SELECT * FROM books WHERE title LIKE 'The%';

-- Books published between 2010 and 2023
SELECT * FROM books WHERE published_year BETWEEN 2010 AND 2023;

-- Books with NULL stock
SELECT * FROM books WHERE stock IS NULL;

-- Sort by published_year DESC, title ASC
SELECT * FROM books ORDER BY published_year DESC, title ASC;
