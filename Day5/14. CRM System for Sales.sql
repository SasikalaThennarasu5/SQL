14. CRM System for Sales
CREATE TABLE leads (
  lead_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  phone VARCHAR(15) UNIQUE,
  email VARCHAR(100) UNIQUE,
  status VARCHAR(20),
  followup_count INT CHECK (followup_count <= 5),
  created_at DATE DEFAULT CURRENT_DATE
);
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  phone VARCHAR(15),
  email VARCHAR(100)
);
CREATE TABLE sales (
  sale_id SERIAL PRIMARY KEY,
  lead_id INT,
  amount DECIMAL(10,2),
  sale_date DATE DEFAULT CURRENT_DATE,
  FOREIGN KEY (lead_id) REFERENCES leads(lead_id)
);
CREATE TABLE followups (
  followup_id SERIAL PRIMARY KEY,
  lead_id INT,
  followup_date DATE,
  notes TEXT,
  FOREIGN KEY (lead_id) REFERENCES leads(lead_id)
);

INSERT INTO leads (name, phone, email, status, followup_count)
VALUES ('Suresh Kumar', '9876543210', 'suresh@gmail.com', 'New', 0);
UPDATE leads SET status = 'Converted' WHERE lead_id = 1;
DELETE FROM leads WHERE created_at < CURRENT_DATE - INTERVAL '1 year';

ALTER TABLE sales DROP CONSTRAINT sales_lead_id_fkey;
ALTER TABLE sales ADD CONSTRAINT sales_lead_id_fkey
  FOREIGN KEY (lead_id) REFERENCES leads(lead_id);

BEGIN;
  INSERT INTO customers (name, phone, email)
    SELECT name, phone, email FROM leads WHERE lead_id = 1;
  INSERT INTO sales (lead_id, amount) VALUES (1, 15000.00);
  UPDATE leads SET status = 'Converted' WHERE lead_id = 1;
COMMIT;
