-- Create Tables
CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100),
    author_id INT,
    genre VARCHAR(50),
    rating DECIMAL(2,1),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    book_id INT,
    customer_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Top-selling authors
SELECT a.author_name, SUM(s.quantity) AS total_sold
FROM authors a
JOIN books b ON a.author_id = b.author_id
JOIN sales s ON b.book_id = s.book_id
GROUP BY a.author_name
ORDER BY total_sold DESC;

-- Books with rating > 4.5 and sold more than 100 times
SELECT b.title, b.rating, SUM(s.quantity) AS total_sales
FROM books b
JOIN sales s ON b.book_id = s.book_id
GROUP BY b.title, b.rating
HAVING b.rating > 4.5 AND SUM(s.quantity) > 100;

-- Customers with more than 5 purchases
SELECT c.customer_name, COUNT(s.sale_id) AS total_purchases
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name
HAVING COUNT(s.sale_id) > 5;

-- INNER JOIN books, sales, customers
SELECT b.title, s.quantity, c.customer_name, s.sale_date
FROM sales s
INNER JOIN books b ON s.book_id = b.book_id
INNER JOIN customers c ON s.customer_id = c.customer_id;

-- FULL OUTER JOIN authors and books (PostgreSQL syntax)
SELECT a.author_name, b.title
FROM authors a
FULL OUTER JOIN books b ON a.author_id = b.author_id;

-- SELF JOIN on books with same genre
SELECT b1.title AS book1, b2.title AS book2, b1.genre
FROM books b1
JOIN books b2 ON b1.genre = b2.genre AND b1.book_id <> b2.book_id;
