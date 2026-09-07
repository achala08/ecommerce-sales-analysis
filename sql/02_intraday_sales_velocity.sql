-- Hourly sales velocity: revenue, order volume, and average order value per hour
SELECT
    EXTRACT(HOUR FROM InvoiceDate) AS order_hour,
    COUNT(DISTINCT InvoiceNo)      AS order_count,
    SUM(line_total)                AS total_revenue,
    ROUND(SUM(line_total) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM sales_clean
GROUP BY EXTRACT(HOUR FROM InvoiceDate)
ORDER BY order_hour;




-- Peak order-volume hour: the single busiest hour by number of orders
SELECT
    EXTRACT(HOUR FROM InvoiceDate) AS order_hour,
    COUNT(DISTINCT InvoiceNo)      AS order_count
FROM sales_clean
GROUP BY EXTRACT(HOUR FROM InvoiceDate)
ORDER BY order_count DESC
LIMIT 1;

-- Peak AOV hour: the single hour with the highest average order value
SELECT
    EXTRACT(HOUR FROM InvoiceDate) AS order_hour,
    ROUND(SUM(line_total) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM sales_clean
GROUP BY EXTRACT(HOUR FROM InvoiceDate)
ORDER BY avg_order_value DESC
LIMIT 1;



-- Category (product) performance: revenue and order volume per product
SELECT
    Description,
    COUNT(DISTINCT InvoiceNo) AS order_count,
    SUM(Quantity)             AS units_sold,
    SUM(line_total)           AS total_revenue
FROM sales_clean
GROUP BY Description
ORDER BY total_revenue DESC
LIMIT 10;














