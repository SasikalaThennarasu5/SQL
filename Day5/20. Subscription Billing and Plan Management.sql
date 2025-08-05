20. Subscription Billing and Plan Management
CREATE TABLE plans (
  plan_id INT PRIMARY KEY,
  name VARCHAR(100),
  start_date DATE,
  end_date DATE,
  CHECK (start_date < end_date)
);

CREATE TABLE users (
  user_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE subscriptions (
  subscription_id INT PRIMARY KEY,
  user_id INT,
  plan_id INT,
  renewal_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  subscription_id INT,
  amount DECIMAL(10, 2),
  payment_date DATE,
  FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

-- Delete expired plans
DELETE FROM plans WHERE end_date < CURRENT_DATE;

-- Use SAVEPOINT before renewal update
BEGIN;
SAVEPOINT before_renewal;
UPDATE subscriptions SET renewal_date = renewal_date + INTERVAL '30 days' WHERE subscription_id = 1;
-- If something fails: ROLLBACK TO SAVEPOINT before_renewal;
COMMIT;

-- Ensure durability: commit before disconnect
BEGIN;
UPDATE payments SET amount = 500.00 WHERE payment_id = 1;
COMMIT;