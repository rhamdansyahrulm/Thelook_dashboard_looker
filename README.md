# [TheLook E-commerce Dashboard](https://lookerstudio.google.com/reporting/4f400ea8-3920-47c1-a437-b47fae012e71)

<div align="center">
    <img src="https://github.com/rhamdansyahrulm/Thelook_dashboard_looker/assets/141615487/2e1e235d-2fad-472a-9894-169c1dbfab5b" alt="Ecuador's Store Dashboard" width="45%">
  <a href="https://public.tableau.com/views/EcuadorsStoreSales/products?:language=en-US&:display_count=n&:origin=viz_share_link">
    <img src="https://github.com/rhamdansyahrulm/Thelook_dashboard_looker/assets/141615487/2e1e235d-2fad-472a-9894-169c1dbfab5b" alt="Ecuador's Store Dashboard" width="45%">
  </a>
</div>

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

## **2. Events**

<div align="center">
  
| id       | user_id | sequence_number | session_id                            | created_at                | ip_address       | city      | state       | postal_code | browser | traffic_source | uri    | event_type |
|----------|---------|-----------------|---------------------------------------|---------------------------|------------------|-----------|-------------|-------------|---------|----------------|--------|------------|
| 669286   | 51230   | 3               | a0a4a72d-37d3-4088-a039-2ada47b0c746  | 2021-03-19 04:09:47 UTC  | 141.64.73.206    | Bogatynia | Dolnośląskie | 59          | IE      | Adwords        | /cart  | cart       |
| 1209624  | 92856   | 4               | ee89a617-8bcd-4049-b2a1-d143bfeb22ec  | 2020-11-08 13:17:15 UTC  | 10.160.127.212   | Bogatynia | Dolnośląskie | 59          | Chrome  | Email          | /cart  | cart       |
| 966247   | 74298   | 4               | cf7eaef7-e56c-4c9a-b846-5ab011ede964  | 2020-12-25 00:40:01 UTC  | 12.42.10.69      | Bogatynia | Dolnośląskie | 59          | Chrome  | Facebook       | /cart  | cart       |

</div>

The events table records information about the activities performed by users on the TheLook E-Commerce website, including:

<div align="center">
  
| Field Name      | Description                                            |
|-----------------|--------------------------------------------------------|
| `id`              | Unique identifier for each record.                    |
| `user_id`         | Unique identifier for the user associated with the event. |
| `sequence_number` | Indicates the sequence number of the event in the session. |
| `session_id`      | Unique identifier for the session during which the event occurred. |
| `created_at`      | Timestamp indicating when the event took place.       |
| `ip_address`      | The IP address from which the event originated.       |
| `city`            | The city associated with the event.                   |
| `state`           | The state or region associated with the event.        |
| `postal_code`     | Postal code associated with the event.                |
| `browser`         | The web browser used by the user during the event.    |
| `traffic_source`  | Source of the web traffic (e.g., Adwords, Email, Facebook). |
| `uri`             | The URI or page visited during the event.             |
| `event_type`      | Type of event (e.g., "cart" in this case).             |

</div>

## **3. Products**

<div align="center">

| id    | cost                | category | name                                            | brand | retail_price       | department | sku                              | distribution_center_id |
|-------|---------------------|----------|-------------------------------------------------|-------|--------------------|------------|----------------------------------|-----------------------|
| 27569 | 92.6525625942932    | Swim     | 2XU Men's Swimmers Compression Long Sleeve Top | 2XU   | 150.41000366210938 | Men        | B23C5765E165D83AA924FA8F13C05F25 | 1                   |
| 27445 | 24.71966119429112   | Swim     | TYR Sport Men's Square Leg Short Swim Suit    | TYR   | 38.9900016784668   | Men        | 2AB7D3B23574C3DEA2BD278AFD0939AB | 1                   |
| 27457 | 15.897600255095959  | Swim     | TYR Sport Men's Solid Durafast Jammer Swim Suit | TYR   | 27.600000381469727 | Men        | 8F831227B0EB6C6D09A0555531365933 | 1                   |


</div>

The products table records information about the products sold on the TheLook E-Commerce website, including:

<div align="center">
  
| Field Name            | Description                                               |
|-----------------------|-----------------------------------------------------------|
| id                    | Unique identifier for each product.                       |
| cost                  | Cost of the product.                                      |
| category              | Category to which the product belongs (e.g., Swim).     |
| name                  | Name of the product.                                     |
| brand                 | Brand of the product.                                    |
| retail_price          | Retail price of the product.                              |
| department            | Department to which the product belongs (e.g., Men).     |
| sku                   | Stock Keeping Unit (SKU) for the product.                |
| distribution_center_id | Unique identifier for the distribution center.            |

</div>

## **4. Users**

<div align="center">

| id    | first_name | last_name  | email                            | age | gender | state  | street_address        | postal_code  | city         | country  | latitude        | longitude      | traffic_source | created_at                |
|-------|------------|------------|----------------------------------|-----|--------|--------|-----------------------|--------------|--------------|----------|-----------------|----------------|----------------|---------------------------|
| 85925 | Matthew    | Stone      | matthewstone@example.org         | 42  | M      | Mie    | 0113 Ford Throughway | 513-0836     | Suzuka City  | Japan    | 34.85181443     | 136.5087133    | Organic        | 2020-02-20 08:03:00 UTC   |
| 7453  | Benjamin   | Hernandez  | benjaminhernandez@example.net    | 33  | M      | Acre   | 9670 Susan Lodge     | 69917-400    | Rio Branco   | Brasil   | -9.945567619    | -67.83560991   | Facebook       | 2022-06-03 17:57:00 UTC   |
| 12387 | Cynthia    | Pope       | cynthiapope@example.org          | 60  | F      | Acre   | 49767 Warner Drive   | 69917-400    | Rio Branco   | Brasil   | -9.945567619    | -67.83560991   | Organic        | 2021-09-01 01:22:00 UTC   |


</div>

The users table records information about the users of the TheLook E-Commerce website, including:

<div align="center">
  
| Field Name      | Description                                              |
|-----------------|----------------------------------------------------------|
| id              | Unique identifier for each user.                         |
| first_name      | The user's first name.                                   |
| last_name       | The user's last name.                                    |
| email           | The user's email address.                               |
| age             | The age of the user.                                     |
| gender          | The gender of the user (M for Male, F for Female).       |
| state           | The state or region where the user resides.             |
| street_address  | The user's street address.                               |
| postal_code     | The postal code associated with the user's address.     |
| city            | The city where the user resides.                         |
| country         | The country where the user is located.                  |
| latitude        | Latitude coordinates of the user's location.            |
| longitude       | Longitude coordinates of the user's location.           |
| traffic_source  | The source of web traffic that brought the user (e.g., Organic, Facebook). |
| created_at      | Timestamp indicating when the user was created.         |

</div>
