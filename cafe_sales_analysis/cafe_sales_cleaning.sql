/* ==========================================================
   Project: Café Sales Data Cleaning & Analysis
   Database: first_practice
   Author: Miguel Mora
   Description:
     This SQL script performs a full cleaning and analysis process 
     on café sales data. It removes duplicates, normalizes values, 
     renames columns, recalculates fields, and creates analytical 
     categories for deeper insights (e.g., revenue by category, 
     location, and payment type).
   ========================================================== */

USE first_practice;

------------------------------------------------------------
-- 1. Initial Exploration
------------------------------------------------------------
SELECT * 
FROM dirty_cafe_sales;

-- Uncomment below to create a working copy
/*
CREATE TABLE worksheet LIKE dirty_cafe_sales;

INSERT INTO worksheet
SELECT *
FROM dirty_cafe_sales;
*/

SELECT * 
FROM worksheet;


------------------------------------------------------------
-- 2. Duplicate Detection and Removal
------------------------------------------------------------
-- Check for duplicate transaction IDs
SELECT `Transaction ID` AS transaction_id, COUNT(*) AS duplicate_count
FROM worksheet
GROUP BY `Transaction ID`
HAVING COUNT(*) > 1
LIMIT 10000;

-- Add temporary ID column for reference
ALTER TABLE worksheet
ADD COLUMN temp_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

-- Remove duplicates keeping the earliest transaction_date
WITH ranked_table AS (
    SELECT temp_id, ROW_NUMBER() OVER(PARTITION BY `Transaction ID` ORDER BY `Transaction Date`) AS row_num
    FROM worksheet
)
DELETE FROM worksheet
WHERE temp_id IN (
    SELECT temp_id FROM ranked_table WHERE row_num > 1
);

-- Drop temporary column
ALTER TABLE worksheet DROP COLUMN temp_id;

-- Verify no duplicates remain
SELECT `Transaction ID`, COUNT(*) AS cnt
FROM worksheet
GROUP BY `Transaction ID`
HAVING cnt > 1;


------------------------------------------------------------
-- 3. Rename Columns for Consistency
------------------------------------------------------------
ALTER TABLE worksheet RENAME COLUMN `Transaction ID` TO transaction_id;
ALTER TABLE worksheet RENAME COLUMN `Item` TO item;
ALTER TABLE worksheet RENAME COLUMN `Quantity` TO quantity;
ALTER TABLE worksheet RENAME COLUMN `Price Per Unit` TO price_per_unit;
ALTER TABLE worksheet RENAME COLUMN `Payment Method` TO payment_method;
ALTER TABLE worksheet RENAME COLUMN `Location` TO location;
ALTER TABLE worksheet RENAME COLUMN `Transaction Date` TO transaction_date;
ALTER TABLE worksheet RENAME COLUMN `Total Spent` TO total_spent;


------------------------------------------------------------
-- 4. Recalculate Total Spent
------------------------------------------------------------
ALTER TABLE worksheet DROP COLUMN total_spent;
ALTER TABLE worksheet ADD COLUMN total_spent DECIMAL(10,2) AFTER price_per_unit;

UPDATE worksheet
SET total_spent = quantity * price_per_unit;


------------------------------------------------------------
-- 5. Check Distinct and Invalid Values
------------------------------------------------------------
SELECT DISTINCT payment_method FROM worksheet;
SELECT DISTINCT location FROM worksheet;
SELECT DISTINCT item FROM worksheet;

-- Identify invalid date formats
SELECT DISTINCT transaction_date, COUNT(*)
FROM worksheet
WHERE transaction_date NOT LIKE '20%'
GROUP BY transaction_date;


------------------------------------------------------------
-- 6. Data Normalization
------------------------------------------------------------
-- Remove invalid rows (if any)
DELETE FROM worksheet WHERE transaction_date IS NULL;

-- Standardize invalid or missing text entries
UPDATE worksheet
SET item = 'Unknown'
WHERE item IN ('UNKNOWN', '', 'ERROR') OR item IS NULL;

UPDATE worksheet
SET location = 'Unknown'
WHERE location IN ('UNKNOWN', '', 'ERROR') OR location IS NULL;

UPDATE worksheet
SET payment_method = 'Unknown'
WHERE payment_method IN ('UNKNOWN', '', 'ERROR') OR payment_method IS NULL;

-- Convert invalid dates to NULL and correct type
UPDATE worksheet
SET transaction_date = NULL
WHERE transaction_date IN ('UNKNOWN', '', 'ERROR');

ALTER TABLE worksheet
MODIFY COLUMN transaction_date DATE;


------------------------------------------------------------
-- 7. Detect Erroneous Numeric Values
------------------------------------------------------------
SELECT *
FROM worksheet
WHERE quantity <= 0 OR price_per_unit <= 0;


------------------------------------------------------------
-- 8. Add Analytical Columns
------------------------------------------------------------
-- Payment type grouping
ALTER TABLE worksheet
ADD COLUMN payment_type VARCHAR(20) AFTER payment_method;

UPDATE worksheet
SET payment_type = CASE
    WHEN payment_method IN ('Credit Card', 'Digital Wallet') THEN 'Electronic'
    WHEN payment_method = 'Cash' THEN 'Cash'
    ELSE 'Unknown'
END;

-- Extract month and day names
ALTER TABLE worksheet ADD COLUMN transaction_month VARCHAR(20);
UPDATE worksheet SET transaction_month = MONTHNAME(transaction_date);

ALTER TABLE worksheet ADD COLUMN transaction_day VARCHAR(20);
UPDATE worksheet SET transaction_day = DAYNAME(transaction_date);

-- Item category classification
ALTER TABLE worksheet ADD COLUMN item_category VARCHAR(20) AFTER item;

UPDATE worksheet
SET item_category = CASE
    WHEN item IN ('Coffee', 'Tea', 'Juice', 'Smoothie') THEN 'Drink'
    WHEN item IN ('Salad', 'Sandwich') THEN 'Food'
    WHEN item IN ('Cake', 'Cookie') THEN 'Dessert'
    ELSE 'Unknown'
END;

-- Spending category
ALTER TABLE worksheet ADD COLUMN spending_category VARCHAR(20) AFTER total_spent;

UPDATE worksheet
SET spending_category = CASE
    WHEN total_spent < 5 THEN 'Low'
    WHEN total_spent >= 5 AND total_spent < 15 THEN 'Medium'
    WHEN total_spent >= 15 THEN 'High'
END;

-- Weekday vs Weekend
ALTER TABLE worksheet ADD COLUMN day_type VARCHAR(20);

UPDATE worksheet
SET day_type = CASE
    WHEN transaction_day IN ('Saturday', 'Sunday') THEN 'Weekend'
    WHEN transaction_day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') THEN 'Weekday'
    ELSE NULL
END;

select *
from worksheet
limit 10000;

------------------------------------------------------------
-- 9. Analytical Summary
------------------------------------------------------------
-- General summary metrics
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS unique_transactions,
    SUM(total_spent) AS total_revenue,
    MIN(transaction_date) AS first_date,
    MAX(transaction_date) AS last_date,
    AVG(total_spent) AS avg_transaction
FROM worksheet;

-- Total revenue by item category
SELECT item_category, SUM(total_spent) AS total_revenue
FROM worksheet
GROUP BY item_category
ORDER BY total_revenue DESC;

-- Total revenue by item
SELECT item, SUM(total_spent) AS total_revenue
FROM worksheet
GROUP BY item
ORDER BY total_revenue DESC;

-- Total revenue by day
SELECT transaction_day, SUM(total_spent) AS total_revenue
FROM worksheet
GROUP BY transaction_day
ORDER BY total_revenue DESC;

-- Average spending by day type
SELECT day_type, AVG(total_spent) AS avg_revenue
FROM worksheet
GROUP BY day_type
ORDER BY avg_revenue DESC;

-- Total revenue by location
SELECT location, SUM(total_spent) AS total_revenue
FROM worksheet
GROUP BY location
ORDER BY total_revenue DESC;

-- Total revenue by payment type
SELECT payment_type, SUM(total_spent) AS total_revenue
FROM worksheet
GROUP BY payment_type
ORDER BY total_revenue DESC;

SELECT * from worksheet
LIMIT 10000;