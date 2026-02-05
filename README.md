# Sales-Data-Warehouse-Analytics
This project explores sales performance using a dimensional data warehouse that consist of dimension tables and fact table
Got you — and you’re right. A README is **not** a dump of SQL queries

##  Overview

This project analyzes a sales data warehouse to uncover insights about:

* Revenue performance
* Customer behavior
* Product contribution
* Profitability

The goal is to support **business decision-making and dashboard development** using structured SQL analysis.

**Database:** `data_warehouse`
**Schema:** `gold` (fact + dimensions)

---

# 💰 Revenue Performance

### 1️⃣ Total Sales

Used to understand overall business performance.

```sql
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_table;
```

### 2️⃣ Sales Trend Over Time

Shows whether the business is growing, stagnating, or declining.

```sql
SELECT 
    YEAR(order_date) AS year,
    SUM(sales_amount) AS total_sales
FROM gold.fact_table
GROUP BY YEAR(order_date)
ORDER BY year;
```

---

# 👥 Customer Insights

### 3️⃣ Unique Customers

Measures market reach and customer base size.

```sql
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_table;
```

### 4️⃣ Top Customers by Revenue

Identifies high-value customers for retention strategies.

```sql
SELECT TOP 10 
    c.customer_id,
    SUM(f.sales_amount) AS total_sales
FROM gold.dim_customers c
JOIN gold.fact_table f
    ON c.customer_key = f.customer_key
GROUP BY c.customer_id
ORDER BY total_sales DESC;
```

### 5️⃣ Repeat vs One-Time Customers

Helps evaluate loyalty and customer retention.

```sql
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers
FROM (
    SELECT customer_key,
           COUNT(DISTINCT order_number) AS order_count
    FROM gold.fact_table
    GROUP BY customer_key
) t
GROUP BY 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END;
```

---

# 📦 Product Performance

### 6️⃣ Top Products by Revenue

Shows which products drive the business.

```sql
SELECT TOP 10
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.dim_products p
JOIN gold.fact_table f
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;
```

### 7️⃣ Sales by Category

Used for product strategy and inventory planning.

```sql
SELECT 
    p.category,
    SUM(f.sales_amount) AS total_sales
FROM gold.dim_products p
JOIN gold.fact_table f
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_sales DESC;
```

---

# 📈 Profitability Analysis

### 8️⃣ Gross Profit

Determines actual earnings after product costs.

```sql
SELECT  
    p.product_name,
    SUM(f.sales_amount - (f.quantity * p.product_cost)) AS gross_profit
FROM gold.dim_products p
JOIN gold.fact_table f
    ON p.product_key = f.product_key
GROUP BY p.product_name;
```

### 9️⃣ Products with Negative Margins

Highlights loss-making products requiring pricing review.

```sql
SELECT  
    p.product_name,
    SUM(f.sales_amount - f.quantity * p.product_cost) AS gross_profit
FROM gold.dim_products p
JOIN gold.fact_table f
    ON p.product_key = f.product_key
GROUP BY p.product_name
HAVING SUM(f.sales_amount - f.quantity * p.product_cost) < 0;
```

---

# ⏱️ Operations Insight

### 🔟 Average Delivery Delay

Measures logistics efficiency.

```sql
SELECT 
    AVG(DATEDIFF(DAY, order_date, shipping_date)) AS avg_delivery_delay
FROM gold.fact_table
WHERE shipping_date IS NOT NULL 
  AND order_date IS NOT NULL;
```

---

# 🎯 Key Business Questions Answered

This analysis helps answer:

* Is revenue growing over time?
* Who are the most valuable customers?
* Are customers loyal or one-time buyers?
* Which products generate the most revenue?
* Which products are losing money?
* How efficient is delivery?

---

# 🛠️ Tools Used

* SQL Server
* Star schema data warehouse
* Tableau (dashboard layer)
* GitHub (documentation)




