-- ========================================================================================================
## Order Status
-- ========================================================================================================

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

-- ========================================================================================================
## Revenue by status
-- ========================================================================================================

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

-- ========================================================================================================
## Average Order Quantity (AOQ)
-- ========================================================================================================

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

-- ========================================================================================================
## Purchase Frequency
-- ========================================================================================================

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

-- ========================================================================================================
## Drop-off Rate
-- ========================================================================================================

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

-- ========================================================================================================
## Top Brand Products
-- ========================================================================================================

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

-- ========================================================================================================
## Top Category Products
-- ========================================================================================================

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

-- ========================================================================================================
## Money Spend
-- ========================================================================================================

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







