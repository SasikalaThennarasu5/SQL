-- View hiding internal notes and employee info
CREATE VIEW view_flight_schedule AS
SELECT flight_id, origin, destination, departure_time, arrival_time
FROM flights;

-- Procedure to book a flight and return PNR
DELIMITER //
CREATE PROCEDURE book_flight(
  IN passenger_id INT,
  IN flight_id INT,
  OUT pnr VARCHAR(10)
)
BEGIN
  SET pnr = CONCAT('PNR', FLOOR(RAND()*100000));
  INSERT INTO reservations(passenger_id, flight_id, reservation_date, pnr)
  VALUES (passenger_id, flight_id, CURDATE(), pnr);
END;
//
DELIMITER ;

-- Function to get passenger count
DELIMITER //
CREATE FUNCTION get_passenger_count(flight_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN (
    SELECT COUNT(*) FROM reservations WHERE flight_id = flight_id
  );
END;
//
DELIMITER ;

-- Trigger after check-in to mark as boarded
DELIMITER //
CREATE TRIGGER after_checkin
AFTER UPDATE ON checkins
FOR EACH ROW
BEGIN
  IF NEW.checked_in = TRUE THEN
    UPDATE reservations SET status = 'Boarded' WHERE reservation_id = NEW.reservation_id;
  END IF;
END;
//
DELIMITER ;

-- Secure customer-facing view
CREATE VIEW view_customer_reservations AS
SELECT r.pnr, f.origin, f.destination, f.departure_time
FROM reservations r
JOIN flights f ON r.flight_id = f.flight_id;
