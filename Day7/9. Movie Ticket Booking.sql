-- 1. View to show current movies (hide backend seat hold logic)
CREATE VIEW view_now_showing AS
SELECT movie_id, title, genre, duration, language, show_time
FROM movies
JOIN shows ON movies.movie_id = shows.movie_id
WHERE CURRENT_DATE <= shows.show_date;

-- 2. Procedure to book ticket and update availability
DELIMITER $$
CREATE PROCEDURE book_ticket(IN p_user_id INT, IN p_show_id INT, IN p_seat_no VARCHAR(10))
BEGIN
  DECLARE is_full INT;
  
  SELECT COUNT(*) INTO is_full
  FROM seats
  WHERE show_id = p_show_id AND status = 'available';

  IF is_full = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Houseful: No available seats';
  ELSE
    START TRANSACTION;
      UPDATE seats
      SET status = 'booked', user_id = p_user_id
      WHERE show_id = p_show_id AND seat_no = p_seat_no;
      
      INSERT INTO bookings(user_id, show_id, seat_no, booking_time)
      VALUES (p_user_id, p_show_id, p_seat_no, NOW());
    COMMIT;
  END IF;
END$$
DELIMITER ;

-- 3. Function to get available seats for a show
DELIMITER $$
CREATE FUNCTION get_available_seats(p_show_id INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE seat_count INT;
  SELECT COUNT(*) INTO seat_count
  FROM seats
  WHERE show_id = p_show_id AND status = 'available';
  RETURN seat_count;
END$$
DELIMITER ;

-- 4. Trigger to prevent booking if houseful
DELIMITER $$
CREATE TRIGGER before_booking
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
  DECLARE seat_count INT;
  SELECT COUNT(*) INTO seat_count
  FROM seats
  WHERE show_id = NEW.show_id AND status = 'available';
  
  IF seat_count = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot book ticket: Houseful';
  END IF;
END$$
DELIMITER ;

-- 5. Public access is restricted via views only
-- (Done via 'view_now_showing' instead of direct table access)
