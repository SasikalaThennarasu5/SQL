-- 1.1 Tables (3NF Normalized)
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200),
    author_id INT,
    genre_id INT,
    publisher_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    sale_date DATE,
    quantity INT,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- 1.2 Indexing
CREATE CLUSTERED INDEX idx_book_id ON books(book_id); -- InnoDB clusters by PK by default
CREATE INDEX idx_title ON books(title);
CREATE INDEX idx_author_id ON books(author_id);

-- 1.3 EXPLAIN for optimization
EXPLAIN SELECT * FROM books WHERE title LIKE '%harry%' AND author_id = 5;

-- 1.4 JOIN to list books with publisher and genre
SELECT b.title, a.name AS author, g.name AS genre, p.name AS publisher
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN genres g ON b.genre_id = g.genre_id
JOIN publishers p ON b.publisher_id = p.publisher_id;

-- 1.5 Denormalized monthly sales summary
CREATE TABLE monthly_sales_summary (
    year_month VARCHAR(7),
    book_id INT,
    total_quantity INT,
    PRIMARY KEY (year_month, book_id)
);

INSERT INTO monthly_sales_summary (year_month, book_id, total_quantity)
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS year_month, book_id, SUM(quantity)
FROM sales
GROUP BY year_month, book_id;

-- 1.6 Pagination for best-selling books
SELECT b.title, SUM(s.quantity) AS total_sales
FROM sales s
JOIN books b ON s.book_id = b.book_id
GROUP BY s.book_id
ORDER BY total_sales DESC
LIMIT 0, 10; -- Page 1 (use OFFSET for pagination)
