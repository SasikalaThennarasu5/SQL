-- Pet Adoption Registry

-- Pets not yet adopted and age between 1–5 years
SELECT name, breed, species FROM pets WHERE adopted = 0 AND age BETWEEN 1 AND 5;

-- Breeds containing 'shepherd'
SELECT * FROM pets WHERE breed LIKE '%shepherd%';

-- Pets with NULL owner
SELECT * FROM pets WHERE owner_name IS NULL;

-- List all species
SELECT DISTINCT species FROM pets;

-- Sort by age ASC, name ASC
SELECT * FROM pets ORDER BY age ASC, name ASC;
