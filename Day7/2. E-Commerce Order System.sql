-- View to show order summary (hiding discount logic)
CREATE VIEW view_order_summary AS
SELECT 
    o.order_id,
    c.name AS customer_name,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Stored Procedure to place an order
DELIMITER //
CREATE PROCEDURE place_order(
    IN cust_id INT,
    IN product_id INT,
    IN quantity INT,
    IN discount DECIMAL(5,2)
)
BEGIN
    DECLARE price DECIMAL(10,2);
    DECLARE total DECIMAL(10,2);

    SELECT product_price INTO price FROM products WHERE product_id = product_id;
    SET total = price * quantity - discount;

    INSERT INTO orders (customer_id, total_amount) VALUES (cust_id, total);
    INSERT INTO order_items (order_id, product_id, quantity)
    VALUES (LAST_INSERT_ID(), product_id, quantity);
END;
//
DELIMITER ;

-- Function to get total cost of an order
DELIMITER //
CREATE FUNCTION get_order_total(o_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(quantity * product_price)
    INTO total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = o_id;
    RETURN total;
END;
//
DELIMITER ;

-- Trigger to log new orders
DELIMITER //
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (order_id, action, timestamp)
    VALUES (NEW.order_id, 'Order Placed', NOW());
END;
//
DELIMITER ;

-- Restrict employee access via read-only view
CREATE VIEW view_customer_info AS
SELECT customer_id, name, email FROM customers;

GRANT SELECT ON view_customer_info TO 'employee_user'@'%';
REVOKE ALL PRIVILEGES ON customers FROM 'employee_user'@'%';

