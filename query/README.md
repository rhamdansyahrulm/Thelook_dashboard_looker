# A. Orders Analytics
This repository contains SQL queries for analyzing e-commerce data using BigQuery. The queries provide insights into new user accounts, user distribution, customer status, customer lifetime value (CLV), and more.

## 1. New User Account
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
## 2. New User Account
This query categorizes users based on gender and age groups, providing insights into the distribution of users.

```sql
WITH user_distribution AS (
  -- Subquery to categorize users based on gender and age groups
)

SELECT
  gender,
  age,
  COUNT(id) as total_user
FROM
  user_distribution
GROUP BY
  gender,
  age
ORDER BY
  age;
```

## 3. New User Country Distribution
This query calculates the distribution of new users by country for the previous month.

```sql
SELECT
  country,
  COUNT(id) as total
FROM
  `bigquery-public-data.thelook_ecommerce.users`
WHERE
  EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
  AND 
  EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
GROUP BY
  country
ORDER BY
  country;
```

## 4. New User Traffic Source
This query provides insights into the sources of web traffic for new users in the previous month.

```sql
SELECT
  traffic_source,
  COUNT(id)
FROM
  `bigquery-public-data.thelook_ecommerce.users`
WHERE
  EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
  AND 
  EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
GROUP BY
  traffic_source
ORDER BY
  traffic_source;
```

## 5. Customer Status
This query categorizes customers into "Active," "New," or "Inactive" based on their purchase history.

```sql
WITH order_last_month AS (
  -- Subquery to identify customers with orders in the last month
),
longer AS (
  -- Subquery to identify customers with orders more than one month ago
), 
customer_status_data AS (
  -- Subquery to categorize customers as "Active," "New," or "Inactive"
)

SELECT 
  customer_status,
  COUNT(customer_status) as total_customer
FROM 
  customer_status_data
GROUP BY
  customer_status;
```

## 6. Customer Life Time (CLV)
This query calculates the Customer Lifetime Value (CLV) for customers based on their purchase history.

```sql
WITH customer_purchase_data AS (
  -- Subquery to gather customer purchase data
)

SELECT
  *,
  ROUND((avg_sale_prices * avg_customer_frequency) / avg_customer_life_span, 2) AS CLV
FROM (
  -- Subquery to calculate CLV
);
```










