-- TABLE CREATION

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    join_date DATE
);

CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50)
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(6,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    staff_id INT,
    item_id INT,
    order_type VARCHAR(10), -- 'dine-in' or 'delivery'
    order_date DATE,
    amount DECIMAL(6,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- SAMPLE DATA

INSERT INTO customers VALUES
(1, 'Alice', '1111111111', '2023-01-01'),
(2, 'Bob', '2222222222', '2023-01-10'),
(3, 'Charlie', '3333333333', '2023-02-01'),
(4, 'David', '4444444444', '2023-02-15');

INSERT INTO staff VALUES
(1, 'Emily', 'Waiter'),
(2, 'Frank', 'Waiter'),
(3, 'Grace', 'Chef');

INSERT INTO menu_items VALUES
(1, 'Margherita Pizza', 12.99),
(2, 'Pepperoni Pizza', 14.99),
(3, 'Pasta Alfredo', 11.99),
(4, 'Veg Burger', 9.99);

INSERT INTO orders VALUES
(1, 1, 1, 1, 'dine-in', '2023-03-01', 12.99),
(2, 2, 1, 2, 'delivery', '2023-03-02', 14.99),
(3, 3, 2, 3, 'dine-in', '2023-03-03', 11.99),
(4, 1, 2, 4, 'dine-in', '2023-03-04', 9.99),
(5, 1, 1, 1, 'delivery', '2023-03-05', 12.99),
(6, 2, 2, 3, 'dine-in', '2023-03-06', 11.99),
(7, 3, 2, 1, 'delivery', '2023-03-07', 12.99),
(8, 1, 1, 2, 'dine-in', '2023-03-08', 14.99);

-- QUERIES

-- 1. INNER JOIN to list full orders with customer and waiter info
SELECT o.order_id, c.name AS customer_name, s.name AS staff_name, m.name AS item_name, o.amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN staff s ON o.staff_id = s.staff_id
INNER JOIN menu_items m ON o.item_id = m.item_id;

-- 2. Use LIKE '%Pizza%' to find pizza items
SELECT * FROM menu_items
WHERE name LIKE '%Pizza%';

-- 3. GROUP BY to get total orders per staff
SELECT s.name AS staff_name, COUNT(*) AS total_orders
FROM orders o
JOIN staff s ON o.staff_id = s.staff_id
GROUP BY s.name;

-- 4. ORDER BY amount and customer name
SELECT o.order_id, c.name AS customer_name, o.amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.amount DESC, c.name;

-- 5. CASE WHEN for categorizing customers (New/Returning)
SELECT name,
  CASE
    WHEN customer_id IN (
        SELECT customer_id
        FROM orders
        GROUP BY customer_id
        HAVING COUNT(*) > 1
    ) THEN 'Returning'
    ELSE 'New'
  END AS customer_status
FROM customers;

-- 6. Subquery to find customers who ordered more than 5 times
SELECT name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 5
);

-- 7. UNION to combine dine-in and delivery data
SELECT order_id, customer_id, order_type, amount
FROM orders
WHERE order_type = 'dine-in'
UNION
SELECT order_id, customer_id, order_type, amount
FROM orders
WHERE order_type = 'delivery';
