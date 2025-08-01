-- Create Tables
CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100),
    area VARCHAR(100)
);

CREATE TABLE properties (
    property_id INT PRIMARY KEY,
    agent_id INT,
    location VARCHAR(100),
    price DECIMAL(12, 2),
    type VARCHAR(50),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100)
);

CREATE TABLE inquiries (
    inquiry_id INT PRIMARY KEY,
    property_id INT,
    client_id INT,
    inquiry_date DATE,
    FOREIGN KEY (property_id) REFERENCES properties(property_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- Count properties listed per agent
SELECT a.agent_name, COUNT(p.property_id) AS total_properties
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
GROUP BY a.agent_name;

-- Average property price per location
SELECT location, AVG(price) AS avg_price
FROM properties
GROUP BY location;

-- Agents with > 20 inquiries
SELECT a.agent_name, COUNT(i.inquiry_id) AS total_inquiries
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
JOIN inquiries i ON p.property_id = i.property_id
GROUP BY a.agent_name
HAVING COUNT(i.inquiry_id) > 20;

-- INNER JOIN: properties ↔ agents ↔ inquiries
SELECT p.property_id, p.location, a.agent_name, i.inquiry_date
FROM properties p
JOIN agents a ON p.agent_id = a.agent_id
JOIN inquiries i ON p.property_id = i.property_id;

-- LEFT JOIN: properties ↔ inquiries
SELECT p.property_id, p.location, i.inquiry_date
FROM properties p
LEFT JOIN inquiries i ON p.property_id = i.property_id;

-- SELF JOIN: agents working in the same area
SELECT a1.agent_name AS agent1, a2.agent_name AS agent2, a1.area
FROM agents a1
JOIN agents a2 ON a1.area = a2.area AND a1.agent_id <> a2.agent_id;
