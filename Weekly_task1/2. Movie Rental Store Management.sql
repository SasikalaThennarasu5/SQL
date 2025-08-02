-- 1. Schema Creation

CREATE TABLE genres (
    genre_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(150),
    genre_id INT,
    price DECIMAL(6,2),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    rental_date DATE,
    return_date DATE,
    due_date DATE,
    type VARCHAR(10), -- 'rental' or 'purchase'
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- 2. Subquery to find top 3 rented movies per genre
SELECT * FROM (
  SELECT m.title, g.name AS genre, COUNT(*) AS rent_count,
         RANK() OVER (PARTITION BY g.genre_id ORDER BY COUNT(*) DESC) AS rank
  FROM rentals r
  JOIN movies m ON r.movie_id = m.movie_id
  JOIN genres g ON m.genre_id = g.genre_id
  WHERE r.type = 'rental'
  GROUP BY m.title, g.name, g.genre_id
) AS ranked_movies
WHERE rank <= 3;

-- 3. Search movies by partial title using LIKE
SELECT * FROM movies
WHERE title LIKE '%Avenger%';

-- 4. Aggregate revenue per genre
SELECT g.name AS genre,
       SUM(CASE WHEN r.type = 'rental' THEN m.price ELSE 0 END) AS rental_revenue,
       SUM(CASE WHEN r.type = 'purchase' THEN m.price ELSE 0 END) AS purchase_revenue,
       SUM(m.price) AS total_revenue
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
JOIN genres g ON m.genre_id = g.genre_id
GROUP BY g.genre_id, g.name;

-- 5. Find unreturned movies (return_date IS NULL)
SELECT r.*, m.title, c.name AS customer_name
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.return_date IS NULL;

-- 6. Use CASE to label late returns
SELECT r.rental_id, c.name AS customer, m.title, r.due_date, r.return_date,
       CASE
         WHEN r.return_date IS NULL THEN 'Not Returned'
         WHEN r.return_date > r.due_date THEN 'Late'
         ELSE 'On Time'
       END AS return_status
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
JOIN customers c ON r.customer_id = c.customer_id;

-- 7. Combine rental and purchase data using UNION ALL
SELECT c.name AS customer, m.title, r.rental_date, r.type
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN movies m ON r.movie_id = m.movie_id
WHERE r.type = 'rental'

UNION ALL

SELECT c.name, m.title, r.rental_date, r.type
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN movies m ON r.movie_id = m.movie_id
WHERE r.type = 'purchase';

-- 8. Full customer and rental info using JOIN
SELECT c.customer_id, c.name AS customer, c.email,
       m.title AS movie_title, r.rental_date, r.return_date, r.type
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN movies m ON r.movie_id = m.movie_id;
