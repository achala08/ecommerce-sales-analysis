SELECT
    COUNT(*)                                        AS total_rows,
    COUNT(*) FILTER (WHERE CustomerID IS NULL)      AS null_customer_id,
    COUNT(*) FILTER (WHERE InvoiceNo LIKE 'C%')     AS cancelled_invoices,
    COUNT(*) - COUNT(DISTINCT (InvoiceNo, StockCode, InvoiceDate, CustomerID)) AS approx_duplicates
FROM ecommerce;



DROP TABLE IF EXISTS sales_clean;


CREATE TABLE sales_clean AS
  WITH deduplicated_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY InvoiceNo, StockCode, CustomerID, InvoiceDate
            ORDER BY InvoiceDate ASC
        ) AS row_num
    FROM ecommerce
),
remove_missing_customer_id AS (
    SELECT *
    FROM deduplicated_data
    WHERE row_num = 1
      AND CustomerID IS NOT NULL
),

remove_cancelled_orders AS (
    SELECT *
    FROM remove_missing_customer_id
    WHERE InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
)


SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    (Quantity * UnitPrice)::DECIMAL(12,2) AS line_total,
    CustomerID,
    Country
FROM remove_cancelled_orders;

SELECT COUNT(*) AS clean_row_count FROM sales_clean;






