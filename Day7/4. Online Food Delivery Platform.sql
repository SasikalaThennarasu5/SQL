4. Online Food Delivery Platform

-- View for customers (hides supplier cost)
CREATE VIEW view_menu_items AS
SELECT item_id, item_name, price, description
FROM menu_items;

-- Procedure to place food order and deduct stock
DELIMITER //
CREATE PROCEDURE place_food_order(
  IN user_id INT,
  IN item_id INT,
  IN qty INT
)
BEGIN
  DECLARE cost DECIMAL(10,2);
  SELECT price INTO cost FROM menu_items WHERE item_id = item_id;

  INSERT INTO food_orders (user_id, total_cost, order_time)
  VALUES (user_id, cost * qty, NOW());

  SET @order_id = LAST_INSERT_ID();

  INSERT INTO order_items (order_id, item_id, quantity)
  VALUES (@order_id, item_id, qty);

  UPDATE menu_items
  SET stock = stock - qty
  WHERE item_id = item_id;

  INSERT INTO delivery_queue (order_id, status)
  VALUES (@order_id, 'Queued');
END;
//
DELIMITER ;

-- Function to get delivery ETA
DELIMITER //
CREATE FUNCTION get_delivery_eta(o_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
  DECLARE eta VARCHAR(50);
  SELECT CONCAT(TIMESTAMPADD(MINUTE, 45, order_time)) INTO eta
  FROM food_orders WHERE order_id = o_id;
  RETURN eta;
END;
//
DELIMITER ;

-- Trigger after order placed
DELIMITER //
CREATE TRIGGER after_order_placed
AFTER INSERT ON food_orders
FOR EACH ROW
BEGIN
  INSERT INTO delivery_queue (order_id, status)
  VALUES (NEW.order_id, 'Processing');
END;
//
DELIMITER ;

-- Admins access all tables, customers only views
GRANT SELECT ON view_menu_items TO 'customer'@'%';
REVOKE ALL ON menu_items FROM 'customer'@'%';