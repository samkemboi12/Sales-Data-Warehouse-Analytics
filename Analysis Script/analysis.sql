

```sql
/* =========================================================
   SALES & CUSTOMER ANALYTICS – EXPLORATORY SQL SCRIPT
   =========================================================

   Database: data_warehouse
   Schema: gold

   Purpose of this script:
   -----------------------
   This script performs exploratory data analysis (EDA) on the
   sales data warehouse. It helps stakeholders understand:

   - Overall sales performance
   - Sales trends over time
   - Customer purchasing behavior
   - Product performance and profitability
   - Operational efficiency (shipping & delivery)
   - Revenue patterns (new vs returning customers)

   The queries are grouped into logical sections:
   1. Sales overview
   2. Time-based performance
   3. Customer analytics
   4. Product analytics
   5. Profitability analysis
   6. Behavioral & advanced analytics

   Each query answers a specific business question and can be
   reused for dashboards, reporting, or deeper analysis.

========================================================= */
```

---

##  SALES OVERVIEW

```sql
-- =========================================================
-- SALES OVERVIEW
-- =========================================================

-- This query calculates the total sales generated between
-- the years 2010 and 2012. It helps understand revenue
-- performance within a specific historical period.

use data_warehouse
SELECT SUM(sales_amount) FROM gold.fact_table
WHERE YEAR(order_date) BETWEEN 2010 AND 2012
      AND order_date IS NOT NULL
```

```sql
-- This query analyzes how total sales have changed over time.
-- It groups revenue by year to identify growth trends,
-- declines, or stable performance periods.

USE data_warehouse
GO

SELECT YEAR(order_date) AS order_date,SUM(sales_amount) Total_sales

FROM gold.fact_table

WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)
```

```sql
-- This query counts the number of unique orders recorded
-- in the sales fact table. It indicates transaction volume.

SELECT DISTINCT COUNT(DISTINCT(order_number))
FROM gold.fact_table 
```

```sql
-- This query determines how many unique customers have
-- made purchases in the dataset.

SELECT DISTINCT COUNT(DISTINCT(customer_key))
FROM gold.fact_table
```

```sql
-- This query calculates the total quantity of items sold.
-- It helps measure sales volume and product movement.

SELECT SUM(quantity)
FROM gold.fact_table

SELECT COUNT(DISTINCT(quantity))
FROM gold.fact_table
```

```sql
-- This query computes the average sales amount per order.
-- It provides insight into the typical order value.

SELECT AVG(sales_amount) FROM gold.fact_table
```

```sql
-- This query identifies the earliest and most recent order dates.
-- It helps understand the time coverage of the dataset.

SELECT MIN(order_date) AS EARLIEST,MAX(order_date) AS LATEST FROM gold.fact_table 
```

---

##  TIME-BASED ANALYSIS

```sql
-- =========================================================
-- TIME-BASED SALES ANALYSIS
-- =========================================================

-- This query identifies which year recorded the highest
-- total sales by ranking yearly revenue in descending order.

SELECT YEAR(order_date) AS order_date,SUM(sales_amount) Total_sales
FROM gold.fact_table
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY Total_sales DESC
```

```sql
-- This query analyzes monthly sales patterns to identify
-- seasonality and peak revenue months.

SELECT MONTH(order_date),DATENAME (MONTH, order_date) AS MONTH, SUM(sales_amount) AS TOTAL_SALES FROM gold.fact_table
WHERE DATENAME (MONTH, order_date) IS NOT NULL
GROUP BY DATENAME (MONTH, order_date),MONTH(order_date)
ORDER BY MONTH(order_date)
```

```sql
-- This query estimates Average Order Value (AOV).
-- It divides total sales by number of distinct order dates
-- to understand spending behavior per order cycle.

SELECT * FROM gold.fact_table
SELECT SUM(sales_amount)/COUNT(DISTINCT(order_date)) FROM gold.fact_table
```

```sql
-- This query identifies orders shipped after the due date.
-- It helps detect operational inefficiencies or delays.

SELECT * FROM gold.fact_table
WHERE  shipping_date > due_date
```

```sql
-- This query calculates the average delivery delay in days
-- between order placement and shipping.

SELECT 
    AVG(DATEDIFF(DAY, order_date, shipping_date)) AS avg_delivery_delay_days
FROM gold.fact_table;

SELECT 
    AVG(DATEDIFF(DAY, order_date, shipping_date)) AS avg_delivery_delay_days
FROM gold.fact_table
WHERE shipping_date IS NOT NULL
  AND order_date IS NOT NULL
  AND shipping_date >= order_date;
```

---

##  CUSTOMER ANALYTICS

```sql
-- =========================================================
-- CUSTOMER ANALYSIS
-- =========================================================

-- This query counts customers per country to understand
-- geographic distribution.

SELECT COUNT(customer_id) AS CNT,country AS country
FROM gold.dim_customers
GROUP BY country
ORDER BY CNT DESC;
```

```sql
-- Data cleaning step:
-- Fixes misspelled country name for consistency.

UPDATE gold.dim_customers
SET country = 'United States'
WHERE country = 'Unites States' 
```

```sql
-- This query calculates total revenue generated by each customer.

SELECT DISTINCT (c.customer_id), SUM(f.sales_amount) AS Total_sales
FROM gold.dim_customers c
LEFT JOIN gold.fact_table f
ON c.customer_id= f.customer_key
WHERE f.sales_amount IS NOT NULL
GROUP BY c.customer_id
```

```sql
-- Identifies the top 10 highest-value customers based on total sales.

SELECT TOP 10 c.customer_id, SUM(f.sales_amount) AS Total_sales
FROM gold.dim_customers c
LEFT JOIN gold.fact_table f
ON c.customer_key= f.customer_key
WHERE f.sales_amount IS NOT NULL
GROUP BY c.customer_id
ORDER BY Total_sales DESC
```

```sql
-- Calculates Customer Lifetime Value (CLV) by averaging
-- total revenue generated per customer.

SELECT AVG(Total_sales) AS clv FROM(
SELECT c.customer_id, SUM(f.sales_amount) AS Total_sales
FROM gold.dim_customers c
LEFT JOIN gold.fact_table f
ON c.customer_key= f.customer_key
WHERE f.sales_amount IS NOT NULL
GROUP BY c.customer_id
) AS customer_totals
```

```sql
-- Identifies customers who have placed more than 5 orders,
-- useful for loyalty and retention analysis.

SELECT c.customer_id AS customer,COUNT(DISTINCT(f.order_number)) AS orders
FROM gold.dim_customers c
LEFT JOIN gold.fact_table f
ON c.customer_key=f.customer_key
GROUP BY c.customer_id
HAVING COUNT(DISTINCT(f.order_number))> 5
```

---

##  PRODUCT ANALYTICS

```sql
-- =========================================================
-- PRODUCT PERFORMANCE ANALYSIS
-- =========================================================

-- Calculates total revenue generated per product.

SELECT p.product_name, SUM(f.sales_amount) AS total_sales FROM gold.dim_products p
LEFT JOIN gold.fact_table f
ON p.product_key=f.product_key
WHERE f.sales_amount IS NOT NULL
GROUP BY p.product_name
```

```sql
-- Identifies top 10 best-selling products based on revenue.

SELECT TOP 10 p.product_name, SUM(f.sales_amount) AS total_sales FROM gold.dim_products p
LEFT JOIN gold.fact_table f
ON p.product_key=f.product_key
WHERE f.sales_amount IS NOT NULL
GROUP BY p.product_name
ORDER BY total_sales DESC
```

```sql
-- Identifies top products based on quantity sold
-- rather than revenue.

SELECT TOP 10 p.product_name, SUM(quantity) AS quantity_sold FROM gold.dim_products p
LEFT JOIN gold.fact_table f
ON p.product_key=f.product_key
WHERE f.sales_amount IS NOT NULL
GROUP BY p.product_name
ORDER BY quantity_sold DESC
```

---

## PROFITABILITY ANALYSIS

```sql
-- =========================================================
-- PROFIT & MARGIN ANALYSIS
-- =========================================================

-- Calculates gross profit per product:
-- sales_amount − (quantity × product_cost)

SELECT  p.product_name, SUM(f.sales_amount - ((f.quantity)*(p.product_cost))) AS gross_margin
FROM gold.dim_products p
LEFT JOIN gold.fact_table f
ON p.product_key=f.product_key
WHERE f.sales_amount IS NOT NULL
GROUP BY p.product_name
```

```sql
-- Calculates gross margin percentage per product.

SELECT  
    p.product_name,
    CAST(
        ROUND(
            (SUM(f.sales_amount) - SUM(f.quantity * p.product_cost)) * 1.0 
            / SUM(f.sales_amount),
            2
        ) AS DECIMAL(5,2)
    ) AS gross_margin
FROM gold.dim_products p
LEFT JOIN gold.fact_table f
    ON p.product_key = f.product_key
WHERE f.sales_amount IS NOT NULL
GROUP BY p.product_name;
```

```sql
-- Identifies products generating negative margins,
-- meaning cost exceeds revenue.

SELECT  
    p.product_name,
    SUM(f.sales_amount - f.quantity * p.product_cost) AS gross_profit
FROM gold.dim_products p
LEFT JOIN gold.fact_table f
    ON p.product_key = f.product_key
GROUP BY p.product_name
HAVING SUM(f.sales_amount - f.quantity * p.product_cost) < 0;
```

---

##  ADVANCED BUSINESS ANALYTICS

```sql
-- =========================================================
-- ADVANCED ANALYTICS & BUSINESS INSIGHTS
-- =========================================================

-- Calculates percentage of customers who made only one order.

SELECT 
 COUNT(CASE WHEN order_count = 1 THEN 1 END)  * 100/ COUNT(*) AS pct
 FROM (SELECT customer_key, COUNT(DISTINCT(order_number)) AS order_count FROM gold.fact_table
 GROUP BY customer_key)t
```

```sql
-- Ranks products by sales within each category.

SELECT 
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS sales,
    RANK() OVER (
        PARTITION BY p.category 
        ORDER BY SUM(f.sales_amount) DESC
    ) AS sales_rank
FROM gold.dim_products p
LEFT JOIN gold.fact_table f
    ON p.product_key = f.product_key
WHERE f.sales_amount IS NOT NULL
GROUP BY p.product_name, p.category
ORDER BY p.category, sales_rank;
```

```sql
-- Calculates running cumulative sales over years.

SELECT
    YEAR(order_date) AS year,
    SUM(sales_amount) AS yearly_sales,
    SUM(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)) AS running_total
FROM gold.fact_table
WHERE sales_amount IS NOT NULL AND order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY year;
```

```sql
-- Compares revenue from new customers vs returning customers by year.

WITH first_order AS (
    SELECT 
        customer_key,
        MIN(YEAR(order_date)) AS first_year
    FROM gold.fact_table
    GROUP BY customer_key
)
SELECT
    YEAR(f.order_date) AS order_year,
    SUM(CASE WHEN YEAR(f.order_date) = fo.first_year THEN f.sales_amount ELSE 0 END) AS new_customer_revenue,
    SUM(CASE WHEN YEAR(f.order_date) > fo.first_year THEN f.sales_amount ELSE 0 END) AS returning_customer_revenue
FROM gold.fact_table f
JOIN first_order fo
    ON f.customer_key = fo.customer_key
GROUP BY YEAR(f.order_date)
ORDER BY order_year;
```


