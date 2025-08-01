-- Loans with amount between ₹50,000 and ₹200,000
SELECT applicant_name, amount, status 
FROM loans 
WHERE amount BETWEEN 50000 AND 200000;

-- Loans of type Home or Education
SELECT * FROM loans 
WHERE loan_type IN ('Home', 'Education');

-- Loans with NULL approval date
SELECT * FROM loans 
WHERE approval_date IS NULL;

-- Sort loans by amount descending
SELECT * FROM loans 
ORDER BY amount DESC;
