==========================================================================================================================
                     RETAIL SALES EXPLORATORY DATA ANALYSIS
==========================================================================================================================

-- PROJECT OVERVIEW

-- This project performs a comprehensive Exploratory Data Analysis (EDA) on a retail
-- sales database using PostgreSQL.
--
-- The objective is to understand the structure, quality, and characteristics of the
-- dataset before performing advanced business analysis.
--
-- The project explores database objects, customer and product dimensions, sales
-- timelines, business measures, customer demographics, product hierarchy, revenue
-- distribution, and ranking analysis.
--
-- The insights generated from this exploratory analysis establish a strong
-- analytical foundation for reporting, dashboard development, predictive analytics,
-- and data-driven decision-making.

--------------------------------------------------------------------------------------------------------------------------
BUSINESS PROBLEM
--------------------------------------------------------------------------------------------------------------------------

-- Retail organizations generate large volumes of transactional data every day.
-- However, before meaningful business insights can be generated, analysts must first
-- understand the data itself.
--
-- Exploratory Data Analysis (EDA) helps answer important foundational questions
-- about the database, including:

• What tables are available?

• How is the database structured?

• What customer and product information is available?

• What is the overall time period covered by the data?

• How many customers, products, and transactions exist?

• What are the key business measures available for analysis?

-- Answering these questions ensures the dataset is well understood before
-- developing dashboards, reports, or advanced analytical models.

--------------------------------------------------------------------------------------------------------------------------
TOOLS USED
--------------------------------------------------------------------------------------------------------------------------

• PostgreSQL

• SQL

• Aggregate Functions

• Window Functions

• Common Table Expressions (CTEs)

• CASE Statements

• Ranking Functions

• Date Functions

===============================================================================
DATASET OVERVIEW
===============================================================================

The project uses a retail sales data warehouse consisting of three related tables.

--------------------------------------------------------------------------------
TABLE NAME                 DESCRIPTION
--------------------------------------------------------------------------------

gold.dim_customers         Customer demographic information

gold.dim_products          Product information including categories and costs

gold.fact_sales            Transaction-level sales records including products,
                           customers, orders, quantities, prices, and revenue

===============================================================================
DATABASE CREATION
===============================================================================

CREATE DATABASE datawarehouseanalytics_EDA;

-- Create schema
CREATE SCHEMA gold;

-- Dimension tables
CREATE TABLE gold.dim_customers (
    customer_key     int,
    customer_id      int,
    customer_number  varchar(50),
    first_name       varchar(50),
    last_name        varchar(50),
    country          varchar(50),
    marital_status   varchar(50),
    gender           varchar(50),
    birthdate        date,
    create_date      date
);

CREATE TABLE gold.dim_products (
    product_key   int,
    product_id    int,
    product_number varchar(50),
    product_name  varchar(50),
    category_id   varchar(50),
    category      varchar(50),
    subcategory   varchar(50),
    maintenance   varchar(50),
    cost          int,
    product_line  varchar(50),
    start_date    date
);

CREATE TABLE gold.fact_sales (
    order_number  varchar(50),
    product_key   int,
    customer_key  int,
    order_date    date,
    shipping_date date,
    due_date      date,
    sales_amount  int,
    quantity      smallint,
    price         int
);

-- Load data using COPY (adjust file paths!)
TRUNCATE TABLE gold.dim_customers;
COPY gold.dim_customers
FROM 'D:\SQL Practice\Projects\Project 2\datasets\flat-files\dim_customers.csv'
DELIMITER ',' CSV HEADER;

TRUNCATE TABLE gold.dim_products;
COPY gold.dim_products
FROM 'D:\SQL Practice\Projects\Project 2\datasets\flat-files\dim_products.csv'
DELIMITER ',' CSV HEADER;

TRUNCATE TABLE gold.fact_sales;
COPY gold.fact_sales
FROM 'D:\SQL Practice\Projects\Project 2\datasets\flat-files\fact_sales.csv'
DELIMITER ',' CSV HEADER;

===============================================================================
EXPLORATORY QUESTION 1: UNDERSTANDING THE DATABASE STRUCTURE
===============================================================================

OBJECTIVE

-- Explore the overall structure of the retail sales database by identifying the available tables, schemas, and columns.
-- Understanding the database architecture is the first step in exploratory data analysis, as it provides visibility into the available data assets before performing detailed business analysis.

===============================================================================
SQL QUERY
===============================================================================

--Database Objects Investigation
SELECT *
FROM INFORMATION_SCHEMA.TABLES;


SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'gold'
ORDER BY table_name;

--Database Columns Investigation
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;


SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema='gold'
ORDER BY table_name, ordinal_position;

===============================================================================
EXPLORATORY QUESTION 2: UNDERSTANDING CUSTOMER AND PRODUCT DIMENSIONS
===============================================================================

OBJECTIVE

-- Explore the customer and product dimensions to understand the descriptive information available for analysis.
-- Dimension exploration helps analysts identify customer demographics,geographic distribution, product hierarchy, and business classifications that can later be used for segmentation, filtering, and reporting.

===============================================================================
SQL QUERY
===============================================================================

--Customers - Countries relationship
SELECT DISTINCT country
FROM gold.dim_customers
ORDER BY country;


--Product Seggregations
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;


-- Categorical count of products

SELECT
    category,
    COUNT(*) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

===============================================================================
EXPLORATORY QUESTION 3: UNDERSTANDING THE SALES TIMEFRAME
===============================================================================

OBJECTIVE

-- Explore the temporal characteristics of the retail sales dataset by identifying the overall time period covered by customer records and sales transactions.
-- Understanding the data timeframe helps determine the historical coverage, data recency, and suitability of the dataset for trend analysis, seasonality analysis, and time-based reporting.

===============================================================================
SQL QUERY
===============================================================================

--First order & Last order Date
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order, AGE(MAX(order_date), MIN(order_date)) AS sales_duration
FROM gold.fact_sales


-- Customer registration period

SELECT
    MIN(create_date) AS first_customer_registration,
    MAX(create_date) AS last_customer_registration,
    AGE(MAX(create_date), MIN(create_date)) AS registration_duration
FROM gold.dim_customers;


-- Age range of customers

SELECT
    MIN(birthdate) AS oldest_birthdate,
    MAX(birthdate) AS youngest_birthdate,
    DATE_PART('year', AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_customer_age,
    DATE_PART('year', AGE(CURRENT_DATE, MAX(birthdate))) AS youngest_customer_age
FROM gold.dim_customers;


-- Yearly number of orders placed

SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY order_year;


--Yearly Sales Data
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order,
	DATE_PART('year', MAX(order_date)) - DATE_PART('year', MIN(order_date)) AS date_diff
FROM gold.fact_sales;

===============================================================================
EXPLORATORY QUESTION 4: UNDERSTANDING KEY BUSINESS MEASURES
===============================================================================

OBJECTIVE

-- Explore the key quantitative business measures available in the retail sales dataset to understand the overall business scale and data distribution.
-- This exploration summarizes important sales metrics such as total revenue,order volume, product quantity, customer count, and product count, providing a high-level overview of business activity before conducting detailed analytical reporting.

===============================================================================
SQL QUERY
===============================================================================

--Total Product - Customer Data
SELECT 
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity_sold,
 	ROUND(AVG(price),0) AS average_selling_price,
 	COUNT(DISTINCT order_number) AS total_order,
 	COUNT(DISTINCT product_key) AS total_products,
 	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;


-- Sales amount statistics

SELECT
    MIN(sales_amount) AS minimum_sale,
    MAX(sales_amount) AS maximum_sale,
    ROUND(AVG(sales_amount),2) AS average_sale
FROM gold.fact_sales;


-- Quantity statistics

SELECT
    MIN(quantity) AS minimum_quantity,
    MAX(quantity) AS maximum_quantity,
    ROUND(AVG(quantity),2) AS average_quantity
FROM gold.fact_sales;


--Product pricing

SELECT
    MIN(cost) AS minimum_product_cost,
    MAX(cost) AS maximum_product_cost,
    ROUND(AVG(cost),2) AS average_product_cost
FROM gold.dim_products;

--Consolidated Report--

SELECT 'Total Sales' AS Measure_Name, SUM(sales_amount) AS Measure_Value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity Sold' AS Measure_Name, SUM(quantity) AS Measure_Value
FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS Measure_Name, ROUND(AVG(price),0) AS Measure_Value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS Measure_Name, COUNT(DISTINCT order_number) AS Measure_Value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS Measure_Name,COUNT(DISTINCT product_key) AS Measure_Value
FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS Measure_Name, COUNT(DISTINCT customer_key) AS Measure_Value
FROM gold.dim_customers;

===============================================================================
EXPLORATORY QUESTION 5: UNDERSTANDING BUSINESS MAGNITUDE
===============================================================================

OBJECTIVE

-- Explore the distribution and magnitude of key business dimensions by measuring the number of customers, products, orders, and transactions across different categories.
-- Magnitude analysis helps identify the scale and concentration of business entities, providing insights into customer distribution, product portfolio,and sales activity before performing detailed analytical reporting.

===============================================================================
SQL QUERY
===============================================================================

--total customers by countries
SELECT country, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

--total customers by gender
SELECT gender, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

--total products by category
SELECT category, COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

--Product distribution across subcategories

SELECT
    category,
    subcategory,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY
    category,
    subcategory
ORDER BY
    category,
    total_products DESC;


--average costs in each category
SELECT category, ROUND(AVG(cost)) AS average_cost
FROM gold.dim_products
GROUP BY category;

--total revenue generated by each category
SELECT p.category, SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.category;

--Customer purchasing frequency

SELECT
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    customer_name
ORDER BY total_orders DESC;

--total revenue generated by each customer
SELECT c.customer_key, c.first_name,c.last_name, SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
INNER JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name,c.last_name;

--what is the distribution of sold items across countries
SELECT c.country, SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales AS f
INNER JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY c.country;

-- Product demand

SELECT
    p.product_name,
    COUNT(*) AS total_transactions
FROM gold.fact_sales f
JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_transactions DESC;

--Orders by Year

SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY order_year;

===============================================================================
EXPLORATORY QUESTION 6: IDENTIFYING TOP AND BOTTOM PERFORMERS
===============================================================================

OBJECTIVE

-- Rank customers and products based on key business metrics to identify the highest and lowest performers.
-- Ranking analysis helps highlight the entities that contribute the most (or least) to business performance, enabling analysts to recognize top-performing products, customers, and categories for further investigation.

===============================================================================
SQL QUERY
===============================================================================

-- Top 10 customers by total revenue

SELECT
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Bottom 10 customers by total revenue

SELECT
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    customer_name
ORDER BY total_revenue ASC
LIMIT 10;

--which 5 products generate highest revenue ?
SELECT p.product_name, SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

--what are the 5 worst performing products in terms of sales ?
SELECT p.product_name, SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
LIMIT 5;

-- Rank product categories by total revenue

SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Top customers by purchase frequency

SELECT
    c.customer_key,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    customer_name
ORDER BY total_orders DESC
LIMIT 10;

==========================================================================================================================
					KEY OBSERVATIONS
==========================================================================================================================

• The retail sales database follows a star schema consisting of two dimension tables (Customers and Products) and one fact table (Sales), providing a well-structured foundation for analytical querying.

• The dataset spans multiple years of historical sales transactions, making it suitable for trend analysis, customer lifecycle analysis, and time-based reporting.

• Customer records include valuable demographic attributes such as country, gender, and birthdate, enabling segmentation and customer profiling.

• The product catalog is organized into categories and subcategories, supporting hierarchical product analysis and merchandising insights.

• Overall business measures reveal the scale of operations, including total sales, order volume, customer base, product portfolio, and average selling price.

• Customer and product distributions indicate varying levels of business concentration across countries, categories, and purchasing behaviour.

• Revenue generation is unevenly distributed across products and categories, highlighting opportunities to identify key revenue drivers and underperforming products.

• Ranking analysis successfully identifies the highest-performing customers and products while also revealing low-performing entities that may require further business investigation.

• The exploratory analysis confirms that the dataset is complete, well-structured, and suitable for advanced business analytics, reporting, and dashboard development.

==========================================================================================================================
BUSINESS VALUE
==========================================================================================================================

• Provides a comprehensive understanding of the database structure before performing advanced analytical tasks.

• Validates the availability and quality of customer, product, and sales data required for business reporting.

• Enables analysts to understand data distributions, business scale, and historical coverage prior to developing dashboards or predictive models.

• Identifies key business dimensions and measures that can be leveraged for customer segmentation, product analysis, and revenue reporting.

• Supports informed decision-making by highlighting customer demographics, product portfolio composition, purchasing behaviour, and sales trends.

• Establishes a reusable analytical foundation for Business Intelligence (BI) solutions, KPI reporting, forecasting, and advanced data analytics projects.

==========================================================================================================================
CONCLUSION
==========================================================================================================================

• This Exploratory Data Analysis (EDA) project successfully examined the retail sales database from structural, dimensional, temporal, and business perspectives. By systematically exploring the database schema, customer and product dimensions, sales timeline, business measures, data distributions, and performance rankings, the project established a comprehensive understanding of the dataset before conducting advanced analytics.

• The insights generated through this analysis provide a reliable foundation for developing business reports, interactive dashboards, customer segmentation models, sales performance analysis, forecasting solutions, and other data-driven initiatives. Overall, this project demonstrates a structured and professional approach to understanding business data, preparing it for meaningful analytical and Business Intelligence applications.
