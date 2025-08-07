-- OLTP Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    brand_id INT
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Snowflake Schema (Normalized Dimensions)
-- Dimension: Date
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT
);

-- Dimension: Product (via Snowflake normalization)
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    brand_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);

-- Dimension: Customer (can also be normalized further if needed)
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(100)
);

-- Fact Table
CREATE TABLE fact_orders (
    order_id INT,
    product_id INT,
    customer_id INT,
    date_id INT,
    quantity INT,
    price DECIMAL(10,2),
    total_sales DECIMAL(12,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- ETL Script Example (Pseudo SQL for ETL logic)
-- Extract from OLTP
-- Transform: Clean data (e.g., nulls, formats)
-- Load into fact table
INSERT INTO fact_orders (order_id, product_id, customer_id, date_id, quantity, price, total_sales)
SELECT 
    o.order_id,
    oi.product_id,
    o.customer_id,
    d.date_id,
    oi.quantity,
    oi.price,
    oi.quantity * oi.price AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN dim_date d ON o.order_date = d.full_date;

-- Aggregation Reports

-- Top-Selling Products
SELECT p.name, SUM(f.quantity) AS total_units, SUM(f.total_sales) AS total_revenue
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 10;

-- Seasonal Trends (e.g., Quarter-wise)
SELECT d.year, d.quarter, p.name, SUM(f.total_sales) AS sales
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter, p.name
ORDER BY d.year, d.quarter, sales DESC;

-- OLAP Queries
-- Drill-Down (Quarter → Month)
SELECT d.year, d.month, p.name, SUM(f.total_sales) AS sales
FROM fact_orders f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE d.quarter = 2
GROUP BY d.year, d.month, p.name;

-- Roll-Up (Month → Quarter)
SELECT d.year, d.quarter, SUM(f.total_sales) AS total_sales
FROM fact_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter;

-- Star vs Snowflake Design Comparison (Explanation)
-- STAR: Denormalized, fewer joins, faster for read-heavy OLAP.
-- SNOWFLAKE: Normalized, better for storage and dimension reuse, slightly more joins.

-- Both have trade-offs in performance:
-- Use STAR if performance > space, SNOWFLAKE if maintainability & space > speed.
