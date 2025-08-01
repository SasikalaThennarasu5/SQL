-- Create Tables
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100)
);

CREATE TABLE checkouts (
    checkout_id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    checkout_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE fines (
    fine_id INT PRIMARY KEY,
    member_id INT,
    amount DECIMAL(10, 2),
    reason VARCHAR(255),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- Count books issued per member
SELECT m.member_name, COUNT(c.book_id) AS books_issued
FROM members m
JOIN checkouts c ON m.member_id = c.member_id
GROUP BY m.member_name;

-- Members with fines over ₹500
SELECT m.member_name, SUM(f.amount) AS total_fine
FROM members m
JOIN fines f ON m.member_id = f.member_id
GROUP BY m.member_name
HAVING SUM(f.amount) > 500;

-- Books with > 5 checkouts
SELECT b.title, COUNT(c.checkout_id) AS times_checked_out
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.title
HAVING COUNT(c.checkout_id) > 5;

-- INNER JOIN: checkouts ↔ members ↔ books
SELECT c.checkout_id, m.member_name, b.title, c.checkout_date
FROM checkouts c
JOIN members m ON c.member_id = m.member_id
JOIN books b ON c.book_id = b.book_id;

-- LEFT JOIN: books ↔ checkouts
SELECT b.title, c.checkout_date
FROM books b
LEFT JOIN checkouts c ON b.book_id = c.book_id;

-- SELF JOIN: members who borrowed the same books
SELECT m1.member_name AS member1, m2.member_name AS member2, b.title
FROM checkouts c1
JOIN checkouts c2 ON c1.book_id = c2.book_id AND c1.member_id <> c2.member_id
JOIN members m1 ON c1.member_id = m1.member_id
JOIN members m2 ON c2.member_id = m2.member_id
JOIN books b ON c1.book_id = b.book_id;
