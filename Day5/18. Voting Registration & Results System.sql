18. Voting Registration & Results System
CREATE TABLE voters (
  voter_id INT PRIMARY KEY,
  name VARCHAR(100),
  age INT CHECK (age >= 18),
  UNIQUE (voter_id)
);

CREATE TABLE elections (
  election_id INT PRIMARY KEY,
  title VARCHAR(100)
);

CREATE TABLE candidates (
  candidate_id INT PRIMARY KEY,
  election_id INT,
  name VARCHAR(100),
  FOREIGN KEY (election_id) REFERENCES elections(election_id)
);

CREATE TABLE votes (
  vote_id INT PRIMARY KEY,
  voter_id INT,
  election_id INT,
  candidate_id INT,
  status VARCHAR(20),
  FOREIGN KEY (voter_id) REFERENCES voters(voter_id) ON DELETE CASCADE,
  FOREIGN KEY (election_id) REFERENCES elections(election_id),
  FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id)
);

-- Modify constraints to allow re-voting in test mode
-- (Assume "test_mode" column added separately in app logic or test schema)

-- Transaction: cast vote + log + confirm
BEGIN;
INSERT INTO votes (vote_id, voter_id, election_id, candidate_id, status) VALUES (101, 1, 1, 2, 'submitted');
-- Log to audit table (assume exists): INSERT INTO vote_log (...)
COMMIT;