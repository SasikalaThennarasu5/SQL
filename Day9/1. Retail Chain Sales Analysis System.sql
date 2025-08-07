-- 1. STAR SCHEMA DESIGN

-- Dimension: Time
CREATE TABLE dim_time (
    time_id SERIAL PRIMARY KEY,
    date DATE UNIQUE,
    day INT,
    month INT,
    quarter INT,
    year INT
);

-- Dimension: Store
CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100),
    location VARCHAR(100),
    region VARCHAR(50)
);

-- Dimension: Product
CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10,2)
);

-- Dimension: Customer
CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    gender CHAR(1),
    age INT
);

-- Fact Table: Sales
CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    time_id INT REFERENCES dim_time(time_id),
    store_id INT REFERENCES dim_store(store_id),
    product_id INT REFERENCES dim_product(product_id),
    customer_id INT REFERENCES dim_customer(customer_id),
    quantity INT,
    total_amount DECIMAL(10,2)
);

-----------------------------------------------------------
-- 2. OLTP REAL-TIME PURCHASE LOGGING TABLE (staging)

CREATE TABLE sales_log_oltp (
    log_id SERIAL PRIMARY KEY,
    sale_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    store_name VARCHAR(100),
    product_name VARCHAR(100),
    customer_email VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2)
);

-----------------------------------------------------------
-- 3. DAILY ETL PROCESS (example using INSERT INTO ... SELECT)

-- a) Load time dimension (ensure only new dates are inserted)
INSERT INTO dim_time (date, day, month, quarter, year)
SELECT DISTINCT
    DATE(sale_timestamp),
    EXTRACT(DAY FROM sale_timestamp),
    EXTRACT(MONTH FROM sale_timestamp),
    EXTRACT(QUARTER FROM sale_timestamp),
    EXTRACT(YEAR FROM sale_timestamp)
FROM sales_log_oltp
WHERE DATE(sale_timestamp) NOT IN (SELECT date FROM dim_time);

-- b) Load unique stores
INSERT INTO dim_store (store_name, location, region)
SELECT DISTINCT store_name, 'Unknown', 'Unknown'
FROM sales_log_oltp
WHERE store_name NOT IN (SELECT store_name FROM dim_store);

-- c) Load unique products
INSERT INTO dim_product (product_name, category, brand, price)
SELECT DISTINCT product_name, 'Misc', 'Unknown', unit_price
FROM sales_log_oltp
WHERE product_name NOT IN (SELECT product_name FROM dim_product);

-- d) Load unique customers
INSERT INTO dim_customer (name, email, gender, age)
SELECT DISTINCT 'Unknown', customer_email, 'U', 0
FROM sales_log_oltp
WHERE customer_email NOT IN (SELECT email FROM dim_customer);

-- e) Insert into fact_sales (joining dimensions)
INSERT INTO fact_sales (time_id, store_id, product_id, customer_id, quantity, total_amount)
SELECT
    t.time_id,
    s.store_id,
    p.product_id,
    c.customer_id,
    l.quantity,
    l.quantity * l.unit_price
FROM sales_log_oltp l
JOIN dim_time t ON t.date = DATE(l.sale_timestamp)
JOIN dim_store s ON s.store_name = l.store_name
JOIN dim_product p ON p.product_name = l.product_name
JOIN dim_customer c ON c.email = l.customer_email;

-----------------------------------------------------------
-- 4. OLAP REPORTING

-- a) DAILY SALES
SELECT t.date, SUM(f.total_amount) AS daily_sales
FROM fact_sales f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.date
ORDER BY t.date;

-- b) MONTHLY SALES
SELECT t.month, t.year, SUM(f.total_amount) AS monthly_sales
FROM fact_sales f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.month, t.year
ORDER BY t.year, t.month;

-- c) QUARTERLY SALES
SELECT t.quarter, t.year, SUM(f.total_amount) AS quarterly_sales
FROM fact_sales f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.quarter, t.year
ORDER BY t.year, t.quarter;

-----------------------------------------------------------
-- 5. STAR VS SNOWFLAKE COMPARISON (THEORETICAL)

-- STAR SCHEMA:
-- - Denormalized dimensions (fewer joins)
-- - Faster query performance
-- - Better for OLAP and analytical tools

-- SNOWFLAKE SCHEMA (not implemented here):
-- - Normalized dimensions (e.g., product → brand table)
-- - Reduced data redundancy
-- - Slower queries due to more joins
-- - Better data integrity

-- Use STAR schema for read-heavy, analytical systems.
-- Use SNOWFLAKE for write-heavy, normalized transactional systems.

-- End of Script.
