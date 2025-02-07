CREATE DATABASE VettyDB;
USE VettyDB;


CREATE TABLE transactions (
    buyer_id INT,
    purchase_time TIMESTAMP,
    refund_item TIMESTAMP NULL,
    store_id VARCHAR(10),
    item_id VARCHAR(10),
    gross_transaction_value DECIMAL(10,2)
);


CREATE TABLE items (
    store_id VARCHAR(10),
    item_id VARCHAR(10),
    item_category VARCHAR(50),
    item_name VARCHAR(50)  
    
);



INSERT INTO transactions (buyer_id, purchase_time, refund_item, store_id, item_id, gross_transaction_value) VALUES
(3, '2019-09-19 21:19:06.544', NULL, 'a', 'a1', 58.00),
(12, '2019-12-10 20:10:14.324', '2019-12-15 23:19:06.544', 'b', 'b2', 475.00),
(3, '2020-09-01 23:59:46.561', '2020-09-02 21:22:06.331', 'f', 'f9', 33.00),
(2, '2020-04-30 21:19:06.544', NULL, 'd', 'd3', 250.00),
(1, '2020-10-22 22:20:06.531', NULL, 'f', 'f2', 91.00),
(8, '2020-04-16 21:10:22.214', NULL, 'e', 'e7', 24.00),
(5, '2019-09-23 12:09:35.542', '2019-09-27 02:55:02.114', 'g', 'g6', 61.00);



INSERT INTO items (store_id, item_id, item_category, item_name) VALUES
('a', 'a1', 'pants', 'denim pants'),
('a', 'a2', 'tops', 'blouse'),
('f', 'f1', 'table', 'coffee table'),
('f', 'f5', 'chair', 'lounge chair'),
('f', 'f6', 'chair', 'armchair'),
('d', 'd2', 'jewelry', 'bracelet'),
('b', 'b4', 'earphone', 'airpods'); 

 
 -- 1
 
 SELECT DATE_FORMAT(purchase_time, '%Y-%m') AS purchase_month, COUNT(*) AS purchase_count
FROM transactions
WHERE refund_flag = 0
GROUP BY DATE_FORMAT(purchase_time, '%Y-%m')
ORDER BY purchase_month;

 -- 2
 
 SELECT 
    DATE_FORMAT(purchase_time, '%Y-%m') AS purchase_month, 
    COUNT(*) AS purchase_count
FROM transactions
WHERE refund_item IS NULL  -- Exclude refunded purchases
GROUP BY purchase_month
ORDER BY purchase_month;

-- 3

SELECT store_id, COUNT(*) AS transaction_count
FROM transactions
WHERE DATE_FORMAT(purchase_time, '%Y-%m') = '2020-10'
GROUP BY store_id
HAVING COUNT(*) >= 5;

-- 4
SELECT 
    store_id, 
    MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_item)) AS min_refund_time
FROM transactions
WHERE refund_item IS NOT NULL
GROUP BY store_id;

-- 5 Ans  
WITH FirstPurchase AS (
    SELECT buyer_id, MIN(purchase_time) AS first_purchase_time
    FROM transactions
    GROUP BY buyer_id
)
SELECT i.item_name, COUNT(*) AS order_count
FROM transactions t
JOIN FirstPurchase fp ON t.buyer_id = fp.buyer_id AND t.purchase_time = fp.first_purchase_time
JOIN items i ON t.item_id = i.item_id
GROUP BY i.item_name
ORDER BY order_count DESC
LIMIT 1;

-- 6 Ans  
ALTER TABLE transactions ADD COLUMN refund_eligible BOOLEAN;

UPDATE transactions
SET refund_eligible = CASE 
    WHEN TIMESTAMPDIFF(HOUR, purchase_time, refund_item) <= 72 THEN 1 
    ELSE 0 
END
WHERE refund_item IS NOT NULL;


-- 7 Ans 

SELECT t1.buyer_id, t1.purchase_time
FROM transactions t1
WHERE (
    SELECT COUNT(*)
    FROM transactions t2
    WHERE t1.buyer_id = t2.buyer_id 
    AND t2.purchase_time < t1.purchase_time
) = 1  
AND t1.refund_item IS NULL;


--  8 Ans 
 
WITH RankedTransactions AS (
    SELECT buyer_id, 
           purchase_time, 
           ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS row_num
    FROM transactions
)
SELECT buyer_id, purchase_time AS second_transaction_time
FROM RankedTransactions
WHERE row_num = 2;


