-- Digital Wallet Transactions

-- Transactions between ₹100 and ₹1000
SELECT user_id, amount, txn_type FROM transactions WHERE amount BETWEEN 100 AND 1000;

-- txn_type containing 'recharge'
SELECT * FROM transactions WHERE txn_type LIKE '%recharge%';

-- NULL statuses
SELECT * FROM transactions WHERE status IS NULL;

-- Sort by txn_date DESC
SELECT * FROM transactions ORDER BY txn_date DESC;
