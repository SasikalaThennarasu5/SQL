-- Multi-Tenant SaaS Database
CREATE TABLE tenants (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    tenant_id INT
);

CREATE TABLE data_table (
    id INT PRIMARY KEY,
    tenant_id INT,
    content TEXT
);

-- Tenant isolation query
SELECT * FROM data_table WHERE tenant_id = 1;

-- Partitioning example: count rows per tenant
SELECT tenant_id, COUNT(*) AS rows_count FROM data_table GROUP BY tenant_id;
