16. Loan Application Processing System
CREATE TABLE applicants (
  applicant_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20)
);
CREATE TABLE loans (
  loan_id SERIAL PRIMARY KEY,
  applicant_id INT,
  amount DECIMAL(12,2) CHECK (amount <= 1000000),
  status VARCHAR(20),
  FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id)
);
CREATE TABLE documents (
  doc_id SERIAL PRIMARY KEY,
  applicant_id INT,
  doc_type VARCHAR(50),
  verified BOOLEAN,
  FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id)
);
CREATE TABLE disbursements (
  disbursement_id SERIAL PRIMARY KEY,
  loan_id INT,
  amount DECIMAL(12,2),
  date_disbursed DATE DEFAULT CURRENT_DATE,
  FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

INSERT INTO applicants (name, email, status)
  VALUES ('Meena Raj', 'meena@gmail.com', 'Pending');
INSERT INTO loans (applicant_id, amount, status)
  VALUES (1, 850000, 'Pending');

UPDATE loans SET status = 'Verified' WHERE loan_id = 1;
UPDATE applicants SET status = 'Verified' WHERE applicant_id = 1;
DELETE FROM applicants WHERE status != 'Verified';

BEGIN;
  UPDATE loans SET status = 'Approved' WHERE loan_id = 1;
  SAVEPOINT before_disbursement;
  INSERT INTO disbursements (loan_id, amount) VALUES (1, 850000);
  -- ROLLBACK TO before_disbursement; -- on error
COMMIT;

BEGIN;
  UPDATE documents SET verified = TRUE WHERE applicant_id = 1;
  UPDATE loans SET status = 'Approved' WHERE loan_id = 1;
  INSERT INTO disbursements (loan_id, amount) VALUES (1, 850000);
COMMIT;