
--Revenue 2015
WITH Revenue AS(
	SELECT 
	s15.* , p.ProductPrice 
	FROM AdventureWorks_Sales_2015 AS s15 
	JOIN AdventureWorks_Products AS p
	ON s15.ProductKey = p.ProductKey )
		SELECT SUM(ProductPrice * OrderQuantity)As Revenue_2015 FROM Revenue;
		
		
--Revenue 2016		
		
WITH Revenue AS(
	SELECT 
	s16.* , p.ProductPrice 
	FROM AdventureWorks_Sales_2016 AS s16
	JOIN AdventureWorks_Products AS p
	ON s16.ProductKey = p.ProductKey )
		SELECT SUM(ProductPrice * OrderQuantity) AS Revenue_2016 FROM Revenue;

--Revenue 2017		
WITH Revenue AS(
	SELECT 
	s17.* , p.ProductPrice 
	FROM AdventureWorks_Sales_2017 AS s17
	JOIN AdventureWorks_Products AS p
	ON s17.ProductKey = p.ProductKey )
		SELECT SUM(ProductPrice * OrderQuantity) AS Revenue_2017 FROM Revenue;	
		
		
		
--Total Revenue and Profit
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
) 
SELECT 
ROUND(SUM(p.ProductPrice * all_sales.OrderQuantity) ,2) AS Total_Revenue ,
SUM(all_sales.OrderQuantity*(p.ProductPrice - p.ProductCost)) AS Total_Profit

FROM all_sales
JOIN AdventureWorks_Products AS p
ON p.ProductKey = all_sales.ProductKey;





		
--Top Products in 2015	
WITH Top_Products_2015 AS(
	SELECT 
	s15.OrderDate , p.ProductName ,p.ProductKey , 
	SUM(ProductPrice * OrderQuantity) AS Total_Revenue ,
	SUM(ProductPrice*OrderQuantity - ProductCost*OrderQuantity) AS Total_Profit
	FROM AdventureWorks_Sales_2015 AS s15
	JOIN AdventureWorks_Products AS p
	ON s15.ProductKey = p.ProductKey 
	GROUP BY p.ProductPrice , p.ProductKey )
		SELECT  
		DENSE_RANK() OVER(ORDER BY Total_Revenue DESC) AS RANK , *  
		FROM Top_Products_2015
		LIMIT 10;
		
		
		
		
		
--Bottom Products in 2015	
WITH Bottom_Products_2015 AS(
	SELECT 
	s15.OrderDate , p.ProductName ,p.ProductKey , SUM(ProductPrice * OrderQuantity) AS Total_Revenue
	FROM AdventureWorks_Sales_2015 AS s15
	JOIN AdventureWorks_Products AS p
	ON s15.ProductKey = p.ProductKey 
	GROUP BY p.ProductPrice , p.ProductKey )
		SELECT  
		DENSE_RANK() OVER(ORDER BY Total_Revenue ASC) AS RANK , *  
		FROM Bottom_Products_2015
		LIMIT 12;
		
		
		

		
		
		
		
		
--ALL over Top Products
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
)

SELECT
    p.ProductKey,
    p.ProductName,
    SUM(s.OrderQuantity) AS Total_Units_Sold,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),2)  AS Total_Revenue,
    ROUND(SUM(s.OrderQuantity * p.ProductCost), 2) AS Total_Cost,
    ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 2) AS Total_Profit,
    DENSE_RANK() OVER (
        ORDER BY SUM(s.OrderQuantity * p.ProductPrice) DESC
    ) AS Product_Rank
FROM all_sales s
JOIN adventureworks_products p
    ON s.ProductKey = p.ProductKey
GROUP BY
    p.ProductKey,
    p.ProductName
ORDER BY
    Total_Profit DESC
LIMIT 10;
	

	
	
	
--Revenue and Profit Product Category wise 
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
)
SELECT
    pc.ProductCategoryKey,
    pc.CategoryName,

   COALESCE(ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2), 0) AS Total_Revenue,

    COALESCE(ROUND(SUM(s.OrderQuantity * p.ProductCost), 2), 0) AS Total_Cost,

    COALESCE(ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 2), 0) AS Total_Profit

FROM adventureworks_product_categories pc

LEFT JOIN adventureworks_product_subcategories psc
    ON pc.ProductCategoryKey = psc.ProductCategoryKey

LEFT JOIN adventureworks_products p
    ON psc.ProductSubcategoryKey = p.ProductSubcategoryKey

LEFT JOIN all_sales s
    ON p.ProductKey = s.ProductKey
GROUP BY
    pc.ProductCategoryKey,
    pc.CategoryName
ORDER BY
    Total_Revenue DESC;
    





--Top Products in each category	
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
),

ranked_products AS (

SELECT
    pc.CategoryName,
    p.ProductName , p.ProductKey ,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_Revenue,

    DENSE_RANK() OVER (
        PARTITION BY pc.ProductCategoryKey
        ORDER BY SUM(s.OrderQuantity * p.ProductPrice) DESC
    ) AS Product_Rank

FROM adventureworks_product_categories pc

JOIN adventureworks_product_subcategories psc
    ON pc.ProductCategoryKey = psc.ProductCategoryKey

JOIN adventureworks_products p
    ON psc.ProductSubcategoryKey = p.ProductSubcategoryKey

JOIN all_sales s
    ON p.ProductKey = s.ProductKey

GROUP BY
    pc.ProductCategoryKey,
    pc.CategoryName,
    p.ProductKey,
    p.ProductName
) SELECT * FROM ranked_products 
WHERE Product_Rank = 1;




--Returned Products
SELECT
    pc.CategoryName,
    COUNT(r.ProductKey) AS Total_Returns
FROM AdventureWorks_Returns AS r
JOIN AdventureWorks_Products AS p
    ON r.ProductKey = p.ProductKey
JOIN AdventureWorks_Product_Subcategories AS psc
    ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories AS pc
    ON psc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.CategoryName
ORDER BY Total_Returns DESC;







--Each Customer Revenue and Profit	
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
) 
SELECT 
all_sales.TerritoryKey  , all_sales.ProductKey , 
c.Gender , c.CustomerKey , c.FirstName , c.LastName,C.AnnualIncome, 
SUM(ProductPrice*OrderQuantity) AS Revenue ,
SUM(ProductPrice - ProductCost) AS Profit 

FROM all_sales
JOIN AdventureWorks_Customers AS c 
ON all_sales.CustomerKey = c.CustomerKey

JOIN AdventureWorks_Products AS p
ON all_sales.ProductKey = p.ProductKey
GROUP BY c.CustomerKey
ORDER BY Revenue DESC
LIMIT 5;




--Classification based on frequency of orders	
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
) , 
Customer_Orders AS(

SELECT COUNT(c.CustomerKey) AS Total_Orders , c.FirstName ,c.LastName , all_sales.TerritoryKey  

FROM all_sales
JOIN AdventureWorks_Customers AS c
ON all_sales.CustomerKey = c.CustomerKey

GROUP BY c.CustomerKey
ORDER BY Total_Orders DESC
)

SELECT * ,
CASE WHEN Total_Orders < 5  THEN 'Less_Frequent'
	 WHEN Total_Orders < 20  THEN 'Frequent'
	 WHEN Total_Orders < 40  THEN 'Very_Frequent'
	 WHEN Total_Orders < 70  THEN 'Regular'
END AS Classification
FROM Customer_Orders;





--Gender Classification 
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
) 
SELECT COUNT(c.Gender) AS Number_of_orders, 
c.Gender , 
SUM(ProductPrice*OrderQuantity) AS Revenue ,
SUM(ProductPrice - ProductCost) AS Profit


FROM all_sales
JOIN AdventureWorks_Customers AS c 
ON all_sales.CustomerKey = c.CustomerKey

JOIN AdventureWorks_Products AS p
ON all_sales.ProductKey = p.ProductKey

GROUP BY c.Gender
ORDER BY Number_of_orders DESC;



-- By AnnualIncome
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
),
cleaned_customers AS (
    SELECT 
        CustomerKey,
        CAST(REPLACE(REPLACE(AnnualIncome, '$', ''), ',', '') AS DECIMAL(10,2)) AS NumericIncome
    FROM AdventureWorks_Customers
)
SELECT  
    CASE 
        WHEN c.NumericIncome < 50000 THEN '< $50k'
        WHEN c.NumericIncome BETWEEN 50000 AND 80000 THEN '$50k - $80k'
        WHEN c.NumericIncome > 80000 THEN '$80k+'
        
    END AS Grouping,
    SUM(p.ProductPrice * all_sales.OrderQuantity) AS Revenue,
    SUM((p.ProductPrice - p.ProductCost) * all_sales.OrderQuantity) AS Profit

FROM all_sales
JOIN cleaned_customers AS c ON all_sales.CustomerKey = c.CustomerKey
JOIN AdventureWorks_Products AS p ON all_sales.ProductKey = p.ProductKey

GROUP BY 
    CASE 
        WHEN c.NumericIncome < 50000 THEN '< $50k'
        WHEN c.NumericIncome BETWEEN 50000 AND 80000 THEN '$50k - $80k'
        WHEN c.NumericIncome > 80000 THEN '$80k+'
        
    END
ORDER BY Revenue DESC;















--Customers in 2015 but not in 2016 
SELECT DISTINCT s15.CustomerKey 
FROM adventureworks_sales_2015 s15
WHERE NOT EXISTS (
    SELECT 1
    FROM adventureworks_sales_2016 s16
    WHERE s16.CustomerKey = s15.CustomerKey
);




--Revenue lost when entered 2016
SELECT
    ROUND(SUM(p.ProductPrice * s15.OrderQuantity), 2) AS Revenue,
    ROUND(SUM((p.ProductPrice - p.ProductCost) * s15.OrderQuantity), 2) AS Profit

FROM adventureworks_sales_2015 AS s15

JOIN AdventureWorks_Products AS p
    ON s15.ProductKey = p.ProductKey

WHERE NOT EXISTS (
    SELECT 1
    FROM adventureworks_sales_2016 AS s16
    WHERE s16.CustomerKey = s15.CustomerKey
);





--Customers in 2016 but not in 2015 ie New acquired Customers in 2016
SELECT DISTINCT s16.CustomerKey 
FROM adventureworks_sales_2016 s16
WHERE NOT EXISTS (
    SELECT 1
    FROM adventureworks_sales_2015 s15
    WHERE s16.CustomerKey = s15.CustomerKey
);


--Revenue generated by New customers in 2016
SELECT
    ROUND(SUM(p.ProductPrice * s16.OrderQuantity), 2) AS Revenue,
    ROUND(SUM((p.ProductPrice - p.ProductCost) * s16.OrderQuantity), 2) AS Profit

FROM adventureworks_sales_2016 AS s16

JOIN AdventureWorks_Products AS p
    ON s16.ProductKey = p.ProductKey

WHERE NOT EXISTS (
    SELECT 1
    FROM adventureworks_sales_2015 AS s15
    WHERE s16.CustomerKey = s15.CustomerKey
);



--Revenue generated by customers in 2015 which are in 2016 also(old ones)
SELECT
    ROUND(SUM(s15.OrderQuantity * p.ProductPrice), 2) AS Revenue_2015
FROM adventureworks_sales_2015 s15

JOIN AdventureWorks_Products p
ON s15.ProductKey = p.ProductKey

WHERE EXISTS (
    SELECT 1
    FROM adventureworks_sales_2016 s16
    WHERE s16.CustomerKey = s15.CustomerKey
);




--Revenue generated by same old customers in 2016
SELECT
    ROUND(SUM(s16.OrderQuantity * p.ProductPrice), 2) AS Revenue_2016
FROM adventureworks_sales_2016 s16

JOIN AdventureWorks_Products p
ON s16.ProductKey = p.ProductKey

WHERE EXISTS (
    SELECT 1
    FROM adventureworks_sales_2015 s15
    WHERE s15.CustomerKey = s16.CustomerKey
);







--Territory analysis 
WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
)
SELECT t.Region , t.SalesTerritoryKey , t.Country , COUNT(t.SalesTerritoryKey) AS Times ,

ROUND(SUM(all_sales.OrderQuantity * p.ProductPrice),2) AS Revenue,

    ROUND(
        100 * SUM(all_sales.OrderQuantity * p.ProductPrice)
        / SUM(SUM(all_sales.OrderQuantity * p.ProductPrice)) OVER (),
        2
    ) AS Revenue_Contribution_Percentage
	
FROM all_sales 
JOIN AdventureWorks_Territories AS t
ON all_sales.TerritoryKey = t.SalesTerritoryKey

JOIN AdventureWorks_Customers AS c
ON all_sales.CustomerKey = c.CustomerKey

JOIN AdventureWorks_Products AS p
ON all_sales.ProductKey = P.ProductKey

GROUP BY SalesTerritoryKey
ORDER BY Revenue_Contribution_Percentage DESC;



--MASTER TABLE 

WITH all_sales AS (
    SELECT * FROM adventureworks_sales_2015
    UNION ALL
    SELECT * FROM adventureworks_sales_2016
    UNION ALL
    SELECT * FROM adventureworks_sales_2017
)

SELECT

    -- Customer
    c.CustomerKey,
    c.FirstName,
    c.LastName,
    c.Gender,
    c.AnnualIncome,
    c.Occupation,

    -- Product Category
    pc.ProductCategoryKey,
    pc.CategoryName,

    -- Product
    p.ProductKey,
    p.ProductName,
    p.ProductCost,
    p.ProductPrice,

    -- Sales
    s.OrderNumber,
    s.OrderDate,
    s.OrderQuantity,
    s.TerritoryKey,

    -- Returns
    COALESCE(r.ReturnQuantity, 0) AS ReturnQuantity,

    CASE
        WHEN r.ReturnQuantity IS NULL THEN 'No'
        ELSE 'Yes'
    END AS Returned,

    -- Measures
    ROUND(s.OrderQuantity * p.ProductPrice, 2) AS Revenue,

    ROUND(s.OrderQuantity * p.ProductCost, 2) AS Cost,

    ROUND(
        s.OrderQuantity * (p.ProductPrice - p.ProductCost),
        2
    ) AS Profit,

    ROUND(
        ((p.ProductPrice - p.ProductCost) / p.ProductPrice) * 100,
        2
    ) AS ProfitMargin

FROM all_sales s

LEFT JOIN AdventureWorks_Customers c
    ON s.CustomerKey = c.CustomerKey

LEFT JOIN AdventureWorks_Products p
    ON s.ProductKey = p.ProductKey

LEFT JOIN AdventureWorks_Product_Subcategories psc
    ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey

LEFT JOIN AdventureWorks_Product_Categories pc
    ON psc.ProductCategoryKey = pc.ProductCategoryKey

LEFT JOIN AdventureWorks_Returns r
    ON s.ProductKey = r.ProductKey
   AND s.TerritoryKey = r.TerritoryKey;
















