

	
-- What is total revenue overall for sales in the assigned territory, plus the start date and end date that tell you what period the data covers?
SELECT
    loc.StoreLocation,
    loc.State,
    SUM(s.Sale_Amount)      AS total_revenue,
    MIN(s.Transaction_Date) AS start_date,
    MAX(s.Transaction_Date) AS end_date
FROM Store_Sales AS s
JOIN Store_Locations AS loc
    ON s.Store_ID = loc.StoreId
WHERE loc.StoreLocation = 'Key West'
GROUP BY loc.StoreLocation, loc.State;
-- What is the revenue breakdown by year and month for the sales territory?
SELECT
    YEAR(Transaction_Date)  AS sales_year,
    MONTH(Transaction_Date) AS sales_month,
    SUM(Sale_Amount)        AS monthly_revenue
FROM Store_Sales
WHERE Store_ID = 722
GROUP BY YEAR(Transaction_Date), MONTH(Transaction_Date)
ORDER BY sales_year, sales_month;

-- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
SELECT
    SUM(CASE WHEN s.Store_ID = 722 THEN s.Sale_Amount END) AS key_west_rev,
    SUM(s.Sale_Amount)                                     AS south_region_rev
FROM Store_Sales AS s
JOIN Store_Locations AS loc ON s.Store_ID = loc.StoreId
JOIN Management AS m        ON loc.State = m.State
WHERE m.Region = 'South';

-- What is the number of transactions per month and average transaction amount by product category for the sales territory?
SELECT
    YEAR(s.Transaction_Date)      AS sales_year,
    MONTH(s.Transaction_Date)     AS month_num,
    MONTHNAME(s.Transaction_Date) AS month_name,
    c.Category,
    COUNT(*)                      AS num_transactions,
    ROUND(AVG(s.Sale_Amount), 2)  AS avg_transaction_amt
FROM Store_Sales AS s
JOIN Products AS p              ON s.Prod_Num = p.ProdNum
JOIN Inventory_Categories AS c  ON p.Categoryid = c.Categoryid
WHERE s.Store_ID = 722
GROUP BY YEAR(s.Transaction_Date),
         MONTH(s.Transaction_Date),
         MONTHNAME(s.Transaction_Date),
         c.Category
ORDER BY sales_year, month_num, c.Category;
-- Can you provide a ranking of in-store sales performance by each store in the sales territory, or a ranking of online sales performance by state within an online sales territory?
SELECT
    RANK() OVER (ORDER BY SUM(SalesTotal) DESC) AS sales_rank,
    ShiptoState,
    SUM(SalesTotal) AS total_sales
FROM Online_Sales
GROUP BY ShiptoState
ORDER BY sales_rank;
-- What is your recommendation for where to focus sales attention in the next quarter?
/*
Recommendation:

Based on the revenue analysis, sales attention should focus on
the strongest-performing months identified for Key West.
Key West has maintained a competitive ranking among Florida
locations, indicating it remains a valuable territory.
Additional focus should be placed on product categories that
consistently generate the highest transaction volumes and
average sale amounts.
Monitoring year-over-year growth trends can help identify
whether seasonal promotions should be expanded during the
highest revenue months.
*/
-- Which months and quarters are strongest and weakest for Key West?
SELECT
    MONTH(s.Transaction_Date) AS Month_Num,
    MONTHNAME(s.Transaction_Date) AS Month_Name,
    SUM(s.Sale_Amount) AS Total_Revenue
FROM Store_Sales s
JOIN Store_Locations loc
    ON s.Store_ID = loc.StoreId
WHERE loc.StoreLocation = 'Key West'
GROUP BY
    MONTH(s.Transaction_Date),
    MONTHNAME(s.Transaction_Date)
ORDER BY Total_Revenue DESC;
-- How has revenue changed year over year from 2022 to 2025?
SELECT
    YEAR(Transaction_Date) AS Sales_Year,
    SUM(Sale_Amount) AS Total_Revenue
FROM Store_Sales
WHERE YEAR(Transaction_Date) BETWEEN 2022 AND 2025
GROUP BY YEAR(Transaction_Date)
ORDER BY Sales_Year;

   
 

  
  
  

SELECT
    YEAR(s.Transaction_Date) AS sales_year,
    RANK() OVER (
        PARTITION BY YEAR(s.Transaction_Date)
        ORDER BY SUM(s.Sale_Amount) DESC
    ) AS florida_rank,
    loc.StoreLocation,
    SUM(s.Sale_Amount) AS total_revenue
FROM Store_Sales AS s
JOIN Store_Locations AS loc ON s.Store_ID = loc.StoreId
WHERE loc.State = 'Florida'
GROUP BY YEAR(s.Transaction_Date), loc.StoreLocation
ORDER BY sales_year, florida_rank;
 
SELECT
    RANK() OVER (ORDER BY SUM(s.Sale_Amount) DESC) AS florida_rank,
    loc.StoreLocation,
    SUM(s.Sale_Amount) AS total_revenue
FROM Store_Sales AS s
JOIN Store_Locations AS loc ON s.Store_ID = loc.StoreId
WHERE loc.State = 'Florida'
GROUP BY loc.StoreLocation
ORDER BY florida_rank;
  
 WITH Florida_Rankings AS (
    SELECT
        YEAR(s.Transaction_Date) AS sales_year,
        RANK() OVER (
            PARTITION BY YEAR(s.Transaction_Date)
            ORDER BY SUM(s.Sale_Amount) DESC
        ) AS florida_rank,
        loc.StoreLocation,
        SUM(s.Sale_Amount) AS total_revenue
    FROM Store_Sales AS s
    JOIN Store_Locations AS loc
        ON s.Store_ID = loc.StoreId
    WHERE loc.State = 'Florida'
    GROUP BY YEAR(s.Transaction_Date), loc.StoreLocation
)
SELECT
    sales_year,
    florida_rank,
    StoreLocation,
    total_revenue
FROM Florida_Rankings
WHERE StoreLocation = 'Key West'
ORDER BY sales_year; 
  
  