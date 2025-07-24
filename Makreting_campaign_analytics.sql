CREATE DATABASE marketing_db;
USE marketing_db;
SHOW DATABASES;


SHOW TABLES;

DESC Campaigns;
DESC Engagement;
DESC Sales;

SELECT * FROM CAMPAIGNS;
SELECT * FROM engagement LIMIT 100;
SELECT * FROM sales LIMIT 100;

SELECT (
SELECT COUNT(*) FROM campaigns) AS campaigns_row_count,
(SELECT COUNT(*) FROM engagement) AS engagement_row_count,
(SELECT COUNT(*) FROM sales) AS sales_row_count;

-- checking that which columns has null values in each tables
-- Skipping "Cmapaigns" Table as it has only 5 rows and all are in correct format without any missing values

-- IN Engagement Table the columns are in incorrect format or datatype. so first I need to fix them and then will move for finding the null values

SELECT user_id, count(*) as freq
FROM engagement
group by user_id
order by freq DESC;

SELECT campaign_ID, count(*) as freq
FROM engagement
group by campaign_id
order by freq DESC;

-- This confirms that user_id and campaign id doesn't have any Null values and these are alos TEXT datatype columns

SELECT clicks, count(*) as unique_values
FROM engagement
group by clicks
order by unique_values DESC;

-- There are '' empty strings in the clicks column which counts to 155, otherwise there no other missing values

SELECT impressions, count(*) as unique_vals
FROM engagement
group by impressions
order by unique_vals DESC;

-- There are no nulls or missing values in this column

SELECT time_spent, count(*) as unique_vls
FROM engagement
group by time_spent
order by unique_vls DESC;

-- In the time_spent column there are 142 missing values and are '' EMPTY strings
-- So, need to fix these 2 columns with empty strings : clicks, time_spent

SET SQL_SAFE_UPDATES = 0;

UPDATE engagement
SET
clicks = CASE WHEN TRIM(clicks) = '' THEN NULL ELSE clicks END,
time_spent = CASE WHEN TRIM(time_spent) = '' THEN NULL ELSE time_spent END
WHERE
TRIM(clicks) = '' or TRIM(time_spent) = '';

-- Now change the data type of the columns of engagement table

ALTER TABLE engagement
MODIFY clicks INT,
MODIFY impressions INT,
MODIFY time_spent INT;

-- Now let's do DATA cleaning/profiling for Sales table

SELECT user_id, count(*) AS freq
FROM sales
group by user_id
order by freq DESC;

SELECT 
sum(CASE 
WHEN user_id IS NULL 
or trim(user_id) = '' 
or user_id = '0' 
or lower(trim(user_id)) = 'null' 
THEN 1 ELSE 0 END) 
AS user_idnull
FROM sales;

SELECT 
count(*) AS invalid_user_ids
FROM sales
WHERE 
user_id IS NULL
or trim(user_id) = '0'
or user_id NOT LIKE '%U%'
or trim(user_id) = ''
or lower(trim(user_id)) = 'null';

SELECT * FROM sales
WHERE user_id NOT LIKE 'U%';

SELECT
count(*) FROM sales
WHERE campaign_id IS NULL
or lower(trim(campaign_id)) = 'null'
or trim(campaign_id) = ''
or trim(campaign_id) = '0'
or campaign_id NOT LIKE 'C%';

SELECT campaign_id, count(*) as freq
FROM sales
group by campaign_id
order by freq DESC; 


SELECT revenue, count(*) as freq
FROM sales
group by revenue
order by freq DESC;

SELECT
count(*) AS revenue_null FROM sales
WHERE revenue IS NULL
or trim(revenue) = ''
or lower(trim(revenue)) = 'null';

-- we got there are 100 empty string '' in this column

SELECT sale_date, count(*) as sale_date_null
FROM sales
group by sale_date
order by sale_date_null DESC;

SELECT count(*) as invalid_date
FROM sales
WHERE sale_date IS NULL
or trim(sale_date) = ''
or lower(trim(sale_date)) = 'null'
or trim(sale_date) = '0';

-- So in sales table only one column has invalid or missing values i.e. revenue

UPDATE sales
SET revenue = null
WHERE trim(revenue) = '';

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE sales
MODIFY revenue INT,
MODIFY sale_date DATE;


SELECT c.campaign_name, c.channel, e.impressions, e.clicks  FROM campaigns c
JOIN engagement e
on c.campaign_id = e.campaign_id
order by e.clicks DESC;

SELECT c.campaign_name, s.revenue, s.sale_date
FROM campaigns c
JOIN sales s
on c.campaign_id = s.campaign_id
order by s.sale_date ASC LIMIT 10;


SELECT c.campaign_name, e.impressions, e.clicks, s.revenue
FROM campaigns c
LEFT JOIN 
engagement e on c.campaign_id = e.campaign_id
LEFT JOIN
sales s on c.campaign_id = s.campaign_id
ORDER BY e.clicks DESC;










