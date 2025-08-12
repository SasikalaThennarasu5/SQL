-- Task 13: Library Management System

CREATE TABLE books (
    id INT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100)
);

CREATE TABLE members (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE borrows (
    id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE,
    return_date DATE
);

-- Sample Data
INSERT INTO books VALUES (1, '1984', 'George Orwell'), (2, 'The Hobbit', 'J.R.R. Tolkien');
INSERT INTO members VALUES (1, 'John Doe'), (2, 'Jane Smith');
INSERT INTO borrows VALUES (1, 1, 1, '2025-03-01', NULL);

-- Fine calculation (example: Rs. 10/day after 14 days)
SELECT b.id, m.name, bo.borrow_date,
       CASE 
           WHEN bo.return_date IS NULL AND DATEDIFF(CURDATE(), bo.borrow_date) > 14
           THEN (DATEDIFF(CURDATE(), bo.borrow_date) - 14) * 10
           ELSE 0
       END AS fine
FROM borrows bo
JOIN members m ON bo.member_id = m.id
JOIN books b ON bo.book_id = b.id;