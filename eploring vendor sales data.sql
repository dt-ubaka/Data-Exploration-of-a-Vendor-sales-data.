WITH sku_name_map AS (
    SELECT 
        `Seller Sku`,
        MAX(`Item Name`) AS Product_Name
    FROM total_orders
    WHERE `Item Name` IS NOT NULL AND `Item Name` <> ''
    GROUP BY `Seller Sku`
)
SELECT 
    r.`Seller Sku`,
    m.`Product_Name`,
    COUNT(*) AS Units_Sold,
    SUM(r.amount) AS Total_Revenue
FROM transaction_report r
LEFT JOIN sku_name_map m 
    ON r.`Seller Sku` = m.`Seller Sku`
WHERE 
    LOWER(TRIM(r.`transaction type`)) = 'item price credit'
    AND LOWER(TRIM(r.`order item status`)) = 'delivered'
    AND r.`Seller Sku` NOT IN (
        SELECT DISTINCT r2.`Seller Sku`
        FROM transaction_report r2
        WHERE LOWER(TRIM(r2.`order item status`)) IN 
              ('returned', 'canceled', 'failed', 'pending', 'ready to ship')
    )
GROUP BY 
    r.`Seller Sku`, m.`Product_Name`
ORDER BY 
    Units_Sold DESC, Total_Revenue DESC;
      
SELECT 
    COUNT(DISTINCT `Order No.`) AS Total_Orders,
    SUM(amount) AS Total_Revenue
FROM transaction_report
WHERE LOWER(TRIM(`transaction type`)) = 'item price credit'
  AND LOWER(TRIM(`order item status`)) = 'delivered';

SELECT 
    AVG(`Shipping Fee`) AS Avg_Shipping_Fee,
    MIN(`Shipping Fee`) AS Min_Shipping_Fee,
    MAX(`Shipping Fee`) AS Max_Shipping_Fee
FROM total_orders;

SELECT 
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN LOWER(TRIM(Status)) = 'canceled' THEN 1 ELSE 0 END) AS Canceled_Orders,
    ROUND(
        SUM(CASE WHEN LOWER(TRIM(Status)) = 'canceled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Cancellation_Rate_Percent
FROM total_orders;

SELECT 
    YEARWEEK(`Created At`, 1) AS YearWeek,
    MIN(DATE(`Created At`)) AS Week_Start,
    MAX(DATE(`Created At`)) AS Week_End,
    COUNT(DISTINCT `Order Number`) AS Orders,
    SUM(`Paid Price`) AS Total_Revenue,
    ROUND(AVG(`Paid Price`), 2) AS Avg_Order_Value
FROM total_orders
WHERE LOWER(TRIM(Status)) = 'delivered'
GROUP BY YEARWEEK(`Created At`, 1)
ORDER BY YearWeek;

WITH customer_orders AS (
    SELECT 
        CONCAT(`Customer First Name`, ' ', `Customer Last Name`) AS Customer_Name,
        COUNT(DISTINCT `Order Number`) AS Order_Count
    FROM total_orders
    GROUP BY CONCAT(`Customer First Name`, ' ', `Customer Last Name`)
)
SELECT 
    Customer_Name,
    Order_Count,
    CASE 
        WHEN Order_Count > 1 THEN 'Repeat'
        ELSE 'One-Time'
    END AS Customer_Type
FROM customer_orders
ORDER BY Order_Count DESC;

SELECT 
    CONCAT(`Customer First Name`, ' ', `Customer Last Name`) AS Customer_Name,
    COUNT(DISTINCT `Order Number`) AS Orders,
    SUM(`Paid Price`) AS Total_Spend,
    ROUND(AVG(`Paid Price`), 2) AS Avg_Order_Value
FROM total_orders
WHERE LOWER(TRIM(Status)) = 'delivered'
GROUP BY CONCAT(`Customer First Name`, ' ', `Customer Last Name`)
ORDER BY Total_Spend DESC
LIMIT 20;


