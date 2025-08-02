-- 1. Schema Creation

CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    genre VARCHAR(50),
    price DECIMAL(8,2),
    author_id INT,
    format VARCHAR(20), -- 'ebook' or 'physical'
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    book_id INT,
    customer_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 2. SELECT books and filter by genre
SELECT * FROM books
WHERE genre = 'Fiction';

-- 3. JOIN books with authors and sales
SELECT b.title, a.name AS author_name, o.quantity, o.order_date
FROM orders o
JOIN books b ON o.book_id = b.book_id
JOIN authors a ON b.author_id = a.author_id;

-- 4. Total and average sales per author
SELECT a.name AS author_name,
       SUM(o.quantity * b.price) AS total_sales,
       AVG(o.quantity * b.price) AS avg_sales
FROM authors a
JOIN books b ON a.author_id = b.author_id
JOIN orders o ON b.book_id = o.book_id
GROUP BY a.author_id, a.name;

-- 5. Filter duplicate book titles using DISTINCT
SELECT DISTINCT title FROM books;

-- 6. Filter orders by date using BETWEEN
SELECT * FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- 7. Subquery to find books never sold
SELECT title FROM books
WHERE book_id NOT IN (
    SELECT DISTINCT book_id FROM orders
);

-- 8. Use CASE WHEN to classify sales performance
SELECT b.title,
       SUM(o.quantity) AS total_quantity,
       CASE
         WHEN SUM(o.quantity) >= 100 THEN 'High'
         WHEN SUM(o.quantity) BETWEEN 50 AND 99 THEN 'Medium'
         ELSE 'Low'
       END AS performance
FROM books b
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.book_id, b.title;

-- 9. Sort books by revenue and author name
SELECT b.title, a.name AS author_name,
       SUM(o.quantity * b.price) AS revenue
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.book_id, b.title, a.name
ORDER BY revenue DESC, author_name ASC;

-- 10. UNION physical and ebook sales
SELECT b.title, 'physical' AS format, SUM(o.quantity) AS total_sold
FROM books b
JOIN orders o ON b.book_id = o.book_id
WHERE b.format = 'physical'
GROUP BY b.title

UNION ALL

SELECT b.title, 'ebook' AS format, SUM(o.quantity) AS total_sold
FROM books b
JOIN orders o ON b.book_id = o.book_id
WHERE b.format = 'ebook'
GROUP BY b.title;
