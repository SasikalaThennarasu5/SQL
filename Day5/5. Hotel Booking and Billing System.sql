-- Tables
CREATE TABLE guests (
  guest_id INT PRIMARY KEY,
  name VARCHAR(100),
  phone VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE rooms (
  room_id INT PRIMARY KEY,
  status VARCHAR(20),
  capacity INT
);

CREATE TABLE bookings (
  booking_id INT PRIMARY KEY,
  guest_id INT,
  room_id INT,
  number_of_guests INT CHECK (number_of_guests <= 5),
  FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
  FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  booking_id INT,
  amount DECIMAL(10, 2),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- Transaction
BEGIN;
INSERT INTO bookings (...) VALUES (...);
INSERT INTO payments (...) VALUES (...);
-- On payment failure
ROLLBACK;
COMMIT;
