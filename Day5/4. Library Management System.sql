-- Tables
CREATE TABLE books (
  book_id INT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  isbn VARCHAR(13) UNIQUE
);

CREATE TABLE members (
  member_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE loans (
  loan_id INT PRIMARY KEY,
  book_id INT,
  member_id INT,
  FOREIGN KEY (book_id) REFERENCES books(book_id),
  FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- CHECK constraint (via trigger or logic) for max 3 active loans
-- Transaction for rollback
BEGIN;
-- Check stock manually or via trigger
UPDATE books SET stock = stock - 1 WHERE book_id = 101;
INSERT INTO loans (loan_id, book_id, member_id) VALUES (10, 101, 201);
-- On error
ROLLBACK;
COMMIT;
