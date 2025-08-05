19. Job Portal and Applications
CREATE TABLE recruiters (
  recruiter_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE jobs (
  job_id INT PRIMARY KEY,
  title VARCHAR(100),
  recruiter_id INT,
  deadline DATE,
  FOREIGN KEY (recruiter_id) REFERENCES recruiters(recruiter_id)
);

CREATE TABLE applicants (
  applicant_id INT PRIMARY KEY,
  name VARCHAR(100),
  experience INT CHECK (experience >= 0)
);

CREATE TABLE applications (
  application_id INT PRIMARY KEY,
  job_id INT,
  applicant_id INT,
  status VARCHAR(50),
  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
  FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id),
  UNIQUE (job_id, applicant_id)
);

-- Drop & recreate experience constraint
ALTER TABLE applicants DROP CONSTRAINT applicants_experience_check;
ALTER TABLE applicants ADD CONSTRAINT applicants_experience_check CHECK (experience >= 1);

-- Delete applications after deadline
DELETE FROM applications
WHERE job_id IN (
  SELECT job_id FROM jobs WHERE deadline < CURRENT_DATE
);

-- Transaction to post job + notify
BEGIN;
INSERT INTO jobs (job_id, title, recruiter_id, deadline) VALUES (201, 'Data Analyst', 1, '2025-12-31');
-- Notify logic (assume notification log table)
COMMIT;
