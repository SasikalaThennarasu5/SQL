-- Hotel Guest Registry

-- Guests stayed between two dates (example)
SELECT name, room_type, check_in FROM guests WHERE check_in BETWEEN '2025-07-01' AND '2025-07-31';

-- Guests with NULL payment status
SELECT * FROM guests WHERE payment_status IS NULL;

-- Guests with names starting with 'K'
SELECT * FROM guests WHERE name LIKE 'K%';

-- List room types
SELECT DISTINCT room_type FROM guests;

-- Sort by check_out DESC, name ASC
SELECT * FROM guests ORDER BY check_out DESC, name ASC;
