-- View: Book Availability for members
CREATE VIEW view_book_availability AS
SELECT book_id, title, author, available_copies FROM books;

-- Procedure: Issue Book
DELIMITER $$
CREATE PROCEDURE issue_book(IN m_id INT, IN b_id INT)
BEGIN
  INSERT INTO issues(member_id, book_id, issue_date)
  VALUES (m_id, b_id, CURDATE());
  UPDATE books SET available_copies = available_copies - 1 WHERE book_id = b_id;
END$$
DELIMITER ;

-- Function: Due Date
DELIMITER $$
CREATE FUNCTION get_due_date(issue_date DATE)
RETURNS DATE
DETERMINISTIC
RETURN DATE_ADD(issue_date, INTERVAL 14 DAY);
$$
DELIMITER ;

-- Trigger: After Issue
DELIMITER $$
CREATE TRIGGER after_issue
AFTER INSERT ON issues
FOR EACH ROW
BEGIN
  UPDATE books
  SET available_copies = available_copies - 1
  WHERE book_id = NEW.book_id;
END$$
DELIMITER ;

-- Abstraction via view
GRANT SELECT ON view_book_availability TO 'member'@'%';
