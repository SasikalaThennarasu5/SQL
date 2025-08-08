-- 1. Table Creation
-- Table: users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Table: leads
CREATE TABLE leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    source VARCHAR(100)
);

-- Table: deals
CREATE TABLE deals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lead_id INT NOT NULL,
    user_id INT NOT NULL,
    stage ENUM('Prospecting', 'Qualified', 'Proposal', 'Won', 'Lost') NOT NULL,
    amount DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lead_id) REFERENCES leads(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- 2. Deal Progression Using CTE or Window Function
-- Example using a window function: most recent stage per lead
SELECT *
FROM (
    SELECT 
        d.*,
        ROW_NUMBER() OVER (PARTITION BY lead_id ORDER BY created_at DESC) AS rn
    FROM deals d
) AS ranked
WHERE rn = 1;
 -- 3. Total Amount by Stage (Using GROUP BY)
 -- Total deal amount by stage
SELECT 
    stage,
    SUM(amount) AS total_amount,
    COUNT(*) AS total_deals
FROM deals
GROUP BY stage;
-- 4. Filter Deals by Status and Date
-- Deals in "Proposal" stage this month
SELECT 
    d.id,
    l.name AS lead_name,
    u.name AS assigned_user,
    d.amount,
    d.created_at
FROM deals d
JOIN leads l ON d.lead_id = l.id
JOIN users u ON d.user_id = u.id
WHERE d.stage = 'Proposal'
  AND MONTH(d.created_at) = MONTH(CURDATE())
  AND YEAR(d.created_at) = YEAR(CURDATE());
--  5. Sample Insert Statements
-- Add users and leads
INSERT INTO users (name) VALUES ('Alice'), ('Bob');
INSERT INTO leads (name, source) VALUES ('Acme Corp', 'Website'), ('Beta Inc', 'Referral');

-- Add deals
INSERT INTO deals (lead_id, user_id, stage, amount)
VALUES 
(1, 1, 'Prospecting', 5000.00),
(1, 1, 'Qualified', 5000.00),
(2, 2, 'Proposal', 7500.00);

 