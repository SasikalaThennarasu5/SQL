-- 1. View to show account summary (excluding fraud/internal flags)
CREATE VIEW view_account_summary AS
SELECT account_id, customer_name, balance, last_transaction_date
FROM accounts
WHERE is_flagged = 0;

-- 2. Procedure to transfer funds with balance check
DELIMITER $$
CREATE PROCEDURE transfer_funds(
  IN p_from_ac INT, IN p_to_ac INT, IN p_amount DECIMAL(10,2)
)
BEGIN
  DECLARE current_balance DECIMAL(10,2);

  SELECT balance INTO current_balance FROM accounts WHERE account_id = p_from_ac;

  IF current_balance < p_amount THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient funds';
  ELSE
    START TRANSACTION;
      UPDATE accounts
      SET balance = balance - p_amount
      WHERE account_id = p_from_ac;

      UPDATE accounts
      SET balance = balance + p_amount
      WHERE account_id = p_to_ac;

      INSERT INTO transactions(account_id, type, amount, transaction_time)
      VALUES (p_from_ac, 'debit', p_amount, NOW()),
             (p_to_ac, 'credit', p_amount, NOW());
    COMMIT;
  END IF;
END$$
DELIMITER ;

-- 3. Function to get transaction count for reporting
DELIMITER $$
CREATE FUNCTION get_transaction_count(p_account_id INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE tx_count INT;
  SELECT COUNT(*) INTO tx_count
  FROM transactions
  WHERE account_id = p_account_id;
  RETURN tx_count;
END$$
DELIMITER ;

-- 4. Trigger to prevent overdraft before transfer
DELIMITER $$
CREATE TRIGGER before_transfer
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
  DECLARE current_balance DECIMAL(10,2);
  IF NEW.type = 'debit' THEN
    SELECT balance INTO current_balance FROM accounts WHERE account_id = NEW.account_id;
    IF current_balance < NEW.amount THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Transfer denied: Overdraft not allowed';
    END IF;
  END IF;
END$$
DELIMITER ;

-- 5. Tellers access only through secure view
-- (Handled via 'view_account_summary')
