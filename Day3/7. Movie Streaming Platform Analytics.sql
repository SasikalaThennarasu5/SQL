-- Create Tables
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    author VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE lending (
    lending_id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- List of overdue books (not returned and due date passed)
SELECT m.member_name, b.title, l.borrow_date, l.return_date
FROM lending l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL AND l.borrow_date < CURRENT_DATE - INTERVAL '14 days';

-- Most borrowed books
SELECT b.title, COUNT(*) AS borrow_count
FROM lending l
JOIN books b ON l.book_id = b.book_id
GROUP BY b.title
ORDER BY borrow_count DESC
LIMIT 5;

-- Members who borrowed more than 3 books
SELECT m.member_name, COUNT(*) AS total_books
FROM lending l
JOIN members m ON l.member_id = m.member_id
GROUP BY m.member_name
HAVING COUNT(*) > 3;

-- Number of books borrowed by genre
SELECT b.genre, COUNT(*) AS total_borrowed
FROM lending l
JOIN books b ON l.book_id = b.book_id
GROUP BY b.genre;

-- INNER JOIN: Borrowing details
SELECT m.member_name, b.title, l.borrow_date, l.return_date
FROM lending l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id;

-- LEFT JOIN: Books that have never been borrowed
SELECT b.title
FROM books b
LEFT JOIN lending l ON b.book_id = l.book_id
WHERE l.book_id IS NULL;
