-- Customer dimension (normalized)
CREATE TABLE dim_city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100)
);

CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    address VARCHAR(255),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES dim_city(city_id)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);

-- Restaurant dimension
CREATE TABLE dim_restaurant (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50), -- e.g., Indian, Chinese
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);

-- Driver dimension
CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(100),
    phone_number VARCHAR(20)
);

-- Time dimension
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    order_date DATE,
    order_time TIME,
    month INT,
    quarter INT,
    year INT
);

-- Fact Table
CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    time_id INT,
    food_category VARCHAR(50),
    cost DECIMAL(10,2),
    delivery_time_minutes INT,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);
