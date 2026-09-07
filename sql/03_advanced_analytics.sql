--RECENCY , FREQUENCY , MONETARY(RFM)
WITH last_order_per_customer AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS customer_last_order,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(line_total) AS monetary
    FROM sales_clean
    GROUP BY CustomerID
),
dataset_reference_point AS (
    SELECT MAX(InvoiceDate) AS latest_timestamp
    FROM sales_clean
),
customer_rfm AS (
    SELECT
        l.CustomerID,
        l.frequency,
        l.monetary,
        ROUND(EXTRACT(EPOCH FROM (d.latest_timestamp - l.customer_last_order)) / 60, 1) AS recency_minutes
    FROM last_order_per_customer l
    CROSS JOIN dataset_reference_point d
),
rfm_scores AS (
    SELECT
        CustomerID,
        recency_minutes,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency_minutes DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC)        AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)         AS m_score
    FROM customer_rfm
)
SELECT
    CustomerID,
    recency_minutes, frequency, monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN f_score >= 3 AND m_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 3) THEN 'At-Risk'
        ELSE 'Lost'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_total DESC;




-- Market basket analysis: which product pairs are bought together most often
SELECT
    a.Description AS product_a,
    b.Description AS product_b,
    COUNT(DISTINCT a.InvoiceNo) AS times_bought_together
FROM sales_clean a
JOIN sales_clean b
    ON a.InvoiceNo = b.InvoiceNo
    AND a.StockCode < b.StockCode
GROUP BY a.Description, b.Description
ORDER BY times_bought_together DESC
LIMIT 15;






-- PARETO ANALYSIS (80/20 RULE ON PRODUCTS)
-- Identifies if ~20% of products generate ~80% of total revenue
WITH product_sales AS (
    SELECT 
        Description,
        SUM(Quantity * UnitPrice) AS total_revenue
    FROM sales_clean
    GROUP BY Description
),
ranked_sales AS (
    SELECT 
        Description,
        total_revenue,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS running_total,
        SUM(total_revenue) OVER () AS grand_total
    FROM product_sales
)
SELECT 
    Description,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND((running_total / grand_total) * 100, 2) AS cumulative_revenue_pct
FROM ranked_sales
ORDER BY total_revenue DESC;






-- AVERAGE ORDER QUANTITY PER CUSTOMER (OUTLIER DETECTION)
-- Highlights potential wholesale buyers vs. retail buyers
SELECT 
    CustomerID,
    ROUND(AVG(Quantity), 2) AS avg_units_per_order,
    MAX(Quantity) AS max_units_in_single_order,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_spent
FROM sales_clean
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 10;






--Identifying Order Size Distribution & Outliers
SELECT 
    InvoiceNo,
    CustomerID,
    SUM(Quantity) AS total_items,
    ROUND(SUM(Quantity * UnitPrice), 2) AS order_total,
    NTILE(4) OVER (ORDER BY SUM(Quantity * UnitPrice)) AS spending_quartile
FROM sales_clean
GROUP BY InvoiceNo, CustomerID
ORDER BY order_total DESC;
-- 6. Identifying Order Size Distribution & Outliers
SELECT 
    InvoiceNo,
    CustomerID,
    SUM(Quantity) AS total_items,
    ROUND(SUM(Quantity * UnitPrice), 2) AS order_total,
    NTILE(4) OVER (ORDER BY SUM(Quantity * UnitPrice)) AS spending_quartile
FROM sales_clean
GROUP BY InvoiceNo, CustomerID
ORDER BY order_total DESC;

























