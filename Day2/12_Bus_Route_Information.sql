-- Bus Route Information

-- Buses from Coimbatore to Madurai
SELECT bus_no, departure, arrival FROM routes WHERE origin = 'Coimbatore' AND destination = 'Madurai';

-- Destinations ending with 'pur'
SELECT * FROM routes WHERE destination LIKE '%pur';

-- Use IN for multiple cities
SELECT * FROM routes WHERE destination IN ('Madurai', 'Trichy', 'Salem');

-- NULL status routes
SELECT * FROM routes WHERE status IS NULL;

-- Sort by departure ASC
SELECT * FROM routes ORDER BY departure ASC;
