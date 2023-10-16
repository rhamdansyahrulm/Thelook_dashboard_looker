# [TheLook E-commerce Dashboard](https://lookerstudio.google.com/reporting/4f400ea8-3920-47c1-a437-b47fae012e71)

<b>TheLook E-commerce Dashboard</b> is a GitHub repository housing a Looker dashboard configuration utilizing public data from Google BigQuery for the "thelook_ecommerce" dataset. The dashboard includes two pages: one for order data and another for customer data, offering insights and analytics for effective data exploration. In creating this dashboard using the available dataset, several tables are utilized, including:

## **1. Order Item**

<div align="center">
  
| order_id | user_id | status  | gender | created_at               | returned_at | shipped_at               | delivered_at | num_of_item |
|----------|---------|---------|--------|--------------------------|-------------|--------------------------|--------------|-------------|
| 1        | 1       | Shipped | F      | 2021-06-28 15:42:00 UTC | null        | 2021-06-30 08:38:00 UTC | null         | 1           |
| 3        | 3       | Shipped | F      | 2020-12-26 01:14:00 UTC | null        | 2020-12-28 12:04:00 UTC | null         | 1           |
| 4        | 5       | Shipped | F      | 2020-06-03 17:15:00 UTC | null        | 2020-06-04 07:46:00 UTC | null         | 2           |

</div>

The orders table records general information about each sales transaction, including:

<div align="center">
  
| Field Name    | Description                                             |
| -------------- | --------------------------------------------------------|
| `order_id`       | Unique identifier for each order.                      |
| `user_id`        | Unique identifier for the user who placed the order.  |
| `status`         | Current status of the order (e.g., Shipped).          |
| `gender`         | Gender of the user (e.g., F for Female).              |
| `created_at`     | Timestamp indicating when the order was created.     |
| `returned_at`    | Timestamp indicating when the order was returned (null if not returned). |
| `shipped_at`     | Timestamp indicating when the order was shipped.     |
| `delivered_at`   | Timestamp indicating when the order was delivered (null if not delivered). |
| `num_of_item`    | Number of items in the order.                         |

</div>
