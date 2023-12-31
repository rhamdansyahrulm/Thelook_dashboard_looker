-- ========================================================================================================
## New User Account
-- ========================================================================================================

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

-- ========================================================================================================
## User Distribution
-- ========================================================================================================

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

-- ========================================================================================================
## New User Country Distribution
-- ========================================================================================================

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

-- ========================================================================================================
## New User Traffic Source
-- ========================================================================================================

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

-- ========================================================================================================
## Customer Status
-- ========================================================================================================

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

-- ========================================================================================================
## Customer Life Time (CLV)
-- ========================================================================================================

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
