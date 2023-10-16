# Orders Analytics

This repository contains SQL queries for analyzing e-commerce data using BigQuery. The queries provide insights into new user accounts, user distribution, customer status, customer lifetime value (CLV), and more.

## New User Account

This query calculates the total number of new user accounts created in the previous month and groups them by the day of account creation.

```sql
SELECT
  EXTRACT(DATE FROM created_at) as day_date,
  COUNT(id) as total
FROM
  `bigquery-public-data.thelook_ecommerce.users`
WHERE
  EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
  AND 
  EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
GROUP BY
  day_date
ORDER BY
  day_date;
```
