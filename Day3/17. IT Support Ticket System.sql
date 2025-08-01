-- Create Tables
CREATE TABLE technicians (
    technician_id INT PRIMARY KEY,
    technician_name VARCHAR(100)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    technician_id INT,
    client_id INT,
    issue_type VARCHAR(100),
    resolution_time INT, -- in hours
    status VARCHAR(50),
    FOREIGN KEY (technician_id) REFERENCES technicians(technician_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- Count of tickets per technician
SELECT t.technician_name, COUNT(k.ticket_id) AS ticket_count
FROM technicians t
JOIN tickets k ON t.technician_id = k.technician_id
GROUP BY t.technician_name;

-- Average resolution time
SELECT AVG(resolution_time) AS avg_resolution_time
FROM tickets;

-- Technicians handling more than 10 tickets
SELECT t.technician_name, COUNT(k.ticket_id) AS total_tickets
FROM technicians t
JOIN tickets k ON t.technician_id = k.technician_id
GROUP BY t.technician_name
HAVING COUNT(k.ticket_id) > 10;

-- INNER JOIN: tickets ↔ technicians
SELECT k.ticket_id, k.issue_type, t.technician_name
FROM tickets k
INNER JOIN technicians t ON k.technician_id = t.technician_id;

-- LEFT JOIN: clients ↔ tickets
SELECT c.client_name, k.issue_type, k.status
FROM clients c
LEFT JOIN tickets k ON c.client_id = k.client_id;

-- SELF JOIN: tickets with same issue types
SELECT t1.ticket_id AS ticket1, t2.ticket_id AS ticket2, t1.issue_type
FROM tickets t1
JOIN tickets t2 ON t1.issue_type = t2.issue_type AND t1.ticket_id <> t2.ticket_id;
