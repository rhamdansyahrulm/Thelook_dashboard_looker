# A. Orders Analytics
This repository contains SQL queries for analyzing e-commerce data using BigQuery. The queries provide insights into various aspects of e-commerce, including order status, revenue, customer behavior, and product analysis.

## 1. Order Status
This query categorizes orders into "Success," "Failed," or "Potential" based on their status (e.g., Complete, Cancelled, Returned). It provides a count of each category for the previous month.

```sql
SELECT
  CASE
    WHEN status = 'Complete' THEN 'Success'
    WHEN status IN ('Cancelled', 'Returned') THEN 'Failed'
    ELSE 'Potential'
  END AS order_status,
  COUNT(id) AS total
FROM
  `bigquery-public-data.thelook_ecommerce.order_items`
WHERE
  EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
  AND 
  EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
GROUP BY
  order_status;
```

## 2. Revenue by Status
This query calculates revenue for orders categorized as "Success," "Failed," or "Potential" based on their status. It groups the results by date and status, providing insights into revenue trends.

```sql
SELECT 
  order_date,
  status,
  SUM(sale_price) as revenue
FROM (
  SELECT
    CASE
      WHEN status = 'Complete' THEN 'Success'
      WHEN status IN ('Cancelled', 'Returned') THEN 'Failed'
      ELSE 'Potential'
    END AS status,
    EXTRACT(DATE FROM created_at) as order_date,
    sale_price
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE
    EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND 
    EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
)
GROUP BY 
  status, order_date
ORDER BY 
  status, order_date;
```

## 3. Average Order Quantity (AOQ)
The Average Order Quantity (AOQ) query calculates the average order quantity for customers in the previous month. It categorizes customers based on their order quantity, providing insights into customer behavior.

```sql
WITH data_order_quantity AS (
  SELECT 
    order_id,
    COUNT(id) as order_quantity
  FROM     
    `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE
    EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND 
    EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    status NOT IN ("Cancelled", "Returned") 
  GROUP BY
    order_id
)

SELECT 
  total_order,
  COUNT(order_quantity) as order_count
FROM (
  SELECT 
    CASE
      WHEN order_quantity > 3 THEN "More Than 3"
      ELSE CAST(order_quantity AS STRING)
    END total_order,
    order_quantity
  FROM 
    data_order_quantity
)
GROUP BY total_order
ORDER BY total_order;
```

## 4. Purchase Frequency
This query calculates the purchase frequency for customers in the previous month. It categorizes customers based on their purchase frequency, providing insights into customer engagement.

```sql
WITH data_order_frequency AS (
  SELECT 
    user_id,
    COUNT(order_id) as order_frequency
  FROM     
    `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE
    EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND 
    EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    status NOT IN ("Cancelled", "Returned") 
  GROUP BY
    user_id
)

SELECT 
  total_order,
  COUNT(order_frequency) as order_count
FROM (
  SELECT 
    CASE
      WHEN order_frequency > 3 THEN "More Than 3"
      ELSE CAST(order_frequency AS STRING)
    END total_order,
    order_frequency
  FROM 
    data_order_frequency
)
GROUP BY total_order
ORDER BY total_order;
```

## 5. Drop-off Rate
The Drop-off Rate query analyzes customer events, categorizing them as "view item," "add to cart," or "purchase." It provides a count of each customer event, helping you understand user behavior.

```sql
WITH data_customer_event AS (
  SELECT 
    id,
    CASE 
      WHEN event_type = "product" THEN "view item"
      WHEN event_type = "cart" THEN "add to chart"
      WHEN event_type = "purchase" THEN "purchase"
    END AS customer_event
  FROM 
    `bigquery-public-data.thelook_ecommerce.events`
  WHERE
    EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH))
    AND 
    EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH))
)

SELECT
  customer_event,
   COUNT(id) AS total_customer_event,
FROM 
  data_customer_event
WHERE
  customer_event IS NOT NULL
GROUP BY
  customer_event
ORDER BY 
  total_customer_event DESC;
```

## 6. Top Brand Products
This query identifies the top brands based on the number of orders for their products in the previous month. It calculates the total orders and their percentage of the total.

```sql
WITH brand_product AS (
  SELECT
    o.id,
    p.brand
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items` o
  LEFT JOIN
    `bigquery-public-data.thelook_ecommerce.products` p
  ON
    o.product_id = p.id
  WHERE
    EXTRACT(MONTH FROM o.created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    EXTRACT(YEAR FROM o.created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    o.status NOT IN ("Cancelled", "Returned")
)

SELECT
  brand,
  COUNT(id) AS total,
  COUNT(id) / SUM(COUNT(id)) OVER () * 100 AS percentage,
FROM
  brand_product
GROUP BY
  brand
ORDER BY
  total DESC
LIMIT 5;
```

## 7. Top Category Products
This query identifies the top product categories based on revenue and total sales. It also breaks down revenue by department (e.g., Men, Women), providing insights into the most profitable categories.

```sql
WITH category_product AS (
  SELECT
    o.id,
    p.category,
    p.department,
    p.retail_price
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items` o
  LEFT JOIN
    `bigquery-public-data.thelook_ecommerce.products` p
  ON
    o.product_id = p.id
  WHERE
    EXTRACT(MONTH FROM o.created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    EXTRACT(YEAR FROM o.created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    o.status NOT IN ("Cancelled", "Returned")
)

SELECT
  category,
  ROUND(sum(retail_price),2) AS revenue,
  ROUND(SUM(CASE WHEN department = 'Men' THEN retail_price ELSE 0 END),2) AS total_men,
  ROUND(SUM(CASE WHEN department = 'Women' THEN retail_price ELSE 0 END),2) AS total_women,
FROM
  category_product
GROUP BY
  category
ORDER BY
  revenue DESC
LIMIT 5;
```

## 8. Total Money Spend
The Money Spend query categorizes orders into different spending ranges (e.g., 0 to 200$, 200$ to 400$, > 400$) based on the retail price of products. It calculates the total orders and their percentage in each spending range.

```sql

WITH money_spend AS (
  SELECT
    o.id,
    p.retail_price,
    CASE
      WHEN p.retail_price BETWEEN 0 AND 200 THEN '0 to 200$'
      WHEN p.retail_price BETWEEN 200 AND 400 THEN '200$ to 400$'
      WHEN p.retail_price BETWEEN 400 AND 1000 THEN '> 400$'
    END AS range_money
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items` o
  LEFT JOIN
    `bigquery-public-data.thelook_ecommerce.products` p
  ON
    o.product_id = p.id
  WHERE
    EXTRACT(MONTH FROM o.created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    EXTRACT(YEAR FROM o.created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    o.status NOT IN ("Cancelled", "Returned")
)

SELECT
  range_money,
  COUNT(id) AS total,
  COUNT(id) / SUM(COUNT(id)) OVER () * 100 AS percentage
FROM
  money_spend
GROUP BY
  range_money
ORDER BY
  total DESC
```

# B. Customers Analytics
This repository contains SQL queries for analyzing e-commerce data using BigQuery. The queries provide insights into new user accounts, user distribution, customer status, customer lifetime value (CLV), and more.

## 1. New Users Account
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
## 2. Users Distribution
This query categorizes users based on gender and age groups, providing insights into the distribution of users.

```sql
WITH user_distribution AS (
  SELECT
    id,
    CASE
      WHEN gender = "M" THEN "Male"
      Else "Female"
    END AS gender,
    CASE
      WHEN age >= 43 AND age <= 58 THEN "X Generation"
      WHEN age >= 27 AND age < 43 THEN "millennial Generation"
      WHEN age >= 11 AND age < 27 THEN "Z Generation"
      ELSE "Others"
    END AS age
  FROM
    `bigquery-public-data.thelook_ecommerce.users`
  WHERE
    EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND 
    EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))

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

## 4. New Users Traffic Source
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

## 5. Customers Status
This query categorizes customers into "Active," "New," or "Inactive" based on their purchase history.

```sql
WITH order_last_month AS (
  SELECT
    user_id,
    date_order
  FROM (
    SELECT
      user_id,
      EXTRACT(date FROM created_at) as date_order,
      ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY created_at DESC) as total_user_order
    FROM
      `bigquery-public-data.thelook_ecommerce.order_items`
    WHERE
      EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
      AND 
      EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
      AND
      status = "Complete" 
  )
  WHERE
    total_user_order = 1
),
longer AS (
  SELECT
    user_id,
    date_order
  FROM (
    SELECT
      user_id,
      EXTRACT(date FROM created_at) as date_order,
      ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY created_at DESC) as total_user_order
    FROM
      `bigquery-public-data.thelook_ecommerce.order_items`
    WHERE
      EXTRACT(MONTH FROM created_at) <= EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH))
      AND 
      EXTRACT(YEAR FROM created_at) <= EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH))
      AND
      status = "Complete" 
  )
  WHERE
    total_user_order = 1
), 
customer_status_data AS (
  SELECT
    x.user_id as last_month_cust,
    y.user_id as two_months_ago_cust,
    CASE
      WHEN x.user_id IS NULL THEN "Inactive"
      WHEN y.user_id IS NULL THEN "New"
      ELSE "Active"
    END AS customer_status
  FROM 
    order_last_month x
  FULL JOIN 
    longer y
  ON
    x.user_id = y.user_id
)

SELECT 
  customer_status,
  COUNT(customer_status) as total_customer
FROM 
  customer_status_data
GROUP BY
  customer_status;
```

## 6. Customers Life Time (CLV)
This query calculates the Customer Lifetime Value (CLV) for customers based on their purchase history.

```sql
WITH customer_purchase_data AS (
  SELECT
    user_id,
    MIN(EXTRACT(DATE FROM created_at)) AS first_purchase,
    MAX(EXTRACT(DATE FROM created_at)) AS last_purchase,
    CEILING(DATE_DIFF(MAX(EXTRACT(DATE FROM created_at)), MIN(EXTRACT(DATE FROM created_at)), MONTH)) AS customer_life_span,
    AVG(sale_price) AS avg_sale_prices,
    COUNT(order_id) AS purchase_frequency
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE
    EXTRACT(MONTH FROM created_at) <= EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND 
    EXTRACT(YEAR FROM created_at) <= EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND
    status = "Complete"
  GROUP BY
    user_id
)

SELECT
  *,
  ROUND((avg_sale_prices * avg_customer_frequency) / avg_customer_life_span,2) AS CLV
FROM (
  SELECT
    ROUND(AVG(customer_life_span),2) AS avg_customer_life_span,
    ROUND(AVG(avg_sale_prices),2) AS avg_sale_prices,
    ROUND(AVG(NULLIF(purchase_frequency / NULLIF(customer_life_span, 0), 0)), 2) AS avg_customer_frequency
  FROM
    customer_purchase_data
);
```










