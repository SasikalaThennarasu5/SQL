-- View of available rooms without maintenance info
CREATE VIEW view_available_rooms AS
SELECT room_id, room_type, rate_per_night, status
FROM rooms
WHERE status = 'available';

-- Procedure to book a room atomically
DELIMITER //
CREATE PROCEDURE book_room(
  IN guest_id INT,
  IN room_id INT,
  IN checkin DATE,
  IN checkout DATE
)
BEGIN
  START TRANSACTION;
    INSERT INTO bookings(guest_id, room_id, checkin_date, checkout_date)
    VALUES (guest_id, room_id, checkin, checkout);
    UPDATE rooms SET status = 'booked' WHERE room_id = room_id;
  COMMIT;
END;
//
DELIMITER ;

-- Function to calculate stay cost
DELIMITER //
CREATE FUNCTION calculate_stay_cost(rate DECIMAL(10,2), checkin DATE, checkout DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN DATEDIFF(checkout, checkin) * rate;
END;
//
DELIMITER ;

-- Trigger to update room availability after booking
DELIMITER //
CREATE TRIGGER after_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
  UPDATE rooms SET status = 'booked' WHERE room_id = NEW.room_id;
END;
//
DELIMITER ;

-- Receptionists use restricted view
CREATE VIEW view_receptionist_rooms AS
SELECT room_id, room_type, rate_per_night
FROM rooms
WHERE status != 'maintenance';
