SELECT* FROM blinkit_data ;

UPDATE blinkit_data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

SELECT DISTINCT Item_Fat_Content FROM blinkit_data; --check the data is it cleaned or not

SELECT CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million
FROM blinkit_data;

SELECT Item_Identifier , COUNT(*) AS DuplicateCount
FROM blinkit_data
GROUP BY Item_Identifier
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC ;

SELECT CAST(AVG(Total_Sales) AS INT) AS Avg_Sales
FROM blinkit_data;

SELECT COUNT(*) AS No_of_Orders
FROM blinkit_data;

SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating
FROM blinkit_data;

SELECT Item_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;

SELECT Item_Fat_Content, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content;

SELECT Outlet_Establishment_Year, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;

SELECT 
    Outlet_Location_Type,
    SUM(CASE WHEN Item_Fat_Content IN ('Low Fat', 'LF', 'low fat') THEN Total_Sales ELSE 0 END) AS Low_Fat,
    SUM(CASE WHEN Item_Fat_Content IN ('Regular', 'reg') THEN Total_Sales ELSE 0 END) AS Regular,
    SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

SELECT Outlet_Type, 
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC

-- Avg weight of items by type
SELECT Item_Type, AVG(Item_Weight) AS Avg_Weight
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Avg_Weight DESC;


-- Sales by Outlet Location Type (Tier)
SELECT Outlet_Location_Type, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;

-- Compare Avg Rating by Location Type
SELECT Outlet_Location_Type, AVG(Rating) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Avg_Rating DESC;

-- Top 10 selling items
SELECT Item_Identifier, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Identifier
ORDER BY Total_Sales DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Sales by Item Type
SELECT Item_Type, SUM(Total_Sales) AS Total_Sales, AVG(Rating) AS Avg_Rating
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;


-- Ranking & Top-N Analysis
WITH RankedSales AS (
    SELECT Outlet_Type, Item_Identifier, SUM(Total_Sales) AS Total_Sales,
           RANK() OVER (PARTITION BY Outlet_Type ORDER BY SUM(Total_Sales) DESC) AS RankNo
    FROM blinkit_data
    GROUP BY Outlet_Type, Item_Identifier
)
SELECT * 
FROM RankedSales
WHERE RankNo <= 3;

-- Time-Based Analysis
SELECT Outlet_Establishment_Year,
       SUM(Total_Sales) AS Total_Sales,
       COUNT(DISTINCT Outlet_Identifier) AS No_Of_Outlets
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;


SELECT 
    CASE 
        WHEN Item_Visibility < 0.05 THEN 'Low Visibility'
        WHEN Item_Visibility BETWEEN 0.05 AND 0.15 THEN 'Medium Visibility'
        ELSE 'High Visibility'
    END AS Visibility_Bucket,
    AVG(Total_Sales) AS Avg_Sales
FROM blinkit_data
GROUP BY 
    CASE 
        WHEN Item_Visibility < 0.05 THEN 'Low Visibility'
        WHEN Item_Visibility BETWEEN 0.05 AND 0.15 THEN 'Medium Visibility'
        ELSE 'High Visibility'
    END
ORDER BY Avg_Sales DESC;


--Funnel analysis
WITH Funnel AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS Listed
    FROM blinkit_data
),
Visible AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS Visible
    FROM blinkit_data
    WHERE Item_Visibility > 0.05   -- stricter condition
),
Purchased AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS Purchased
    FROM blinkit_data
    WHERE Total_Sales > 100        -- not just >0, but >100
),
RepeatBuyers AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS RepeatBuyers
    FROM blinkit_data
    WHERE Total_Sales > (
        SELECT AVG(Total_Sales) FROM blinkit_data   -- relative cutoff
    )
),
HighRated AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS HighRated
    FROM blinkit_data
    WHERE Rating >= 4.5            -- stricter condition
)
SELECT 
    Listed, Visible, Purchased, RepeatBuyers, HighRated
FROM Funnel, Visible, Purchased, RepeatBuyers, HighRated;

--Conversion rates between stages

;WITH Funnel AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS Listed
    FROM blinkit_data
),
Visible AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS Visible
    FROM blinkit_data
    WHERE Item_Visibility > 0.05
),
Purchased AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS Purchased
    FROM blinkit_data
    WHERE Total_Sales > 100
),
RepeatBuyers AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS RepeatBuyers
    FROM blinkit_data
    WHERE Total_Sales > (SELECT AVG(Total_Sales) FROM blinkit_data)
),
HighRated AS (
    SELECT COUNT(DISTINCT Item_Identifier) AS HighRated
    FROM blinkit_data
    WHERE Rating >= 4.5
)
SELECT
    CAST(100.0 * Listed / Listed AS DECIMAL(5,2)) AS Listed_Rate,
    CAST(100.0 * Visible / Listed AS DECIMAL(5,2)) AS Visibility_Rate,
    CAST(100.0 * Purchased / Visible AS DECIMAL(5,2)) AS Purchase_Rate,
    CAST(100.0 * RepeatBuyers / Purchased AS DECIMAL(5,2)) AS Repeat_Rate,
    CAST(100.0 * HighRated / RepeatBuyers AS DECIMAL(5,2)) AS Rating_Rate
FROM Funnel, Visible, Purchased, RepeatBuyers, HighRated;


-- Funnel by Outlet_Type or Outlet_Location_Type

WITH Funnel AS (
    SELECT Outlet_Type, COUNT(DISTINCT Item_Identifier) AS Listed
    FROM blinkit_data
    GROUP BY Outlet_Type
),
Visible AS (
    SELECT Outlet_Type, COUNT(DISTINCT Item_Identifier) AS Visible
    FROM blinkit_data
    WHERE Item_Visibility > 0.05
    GROUP BY Outlet_Type
),
Purchased AS (
    SELECT Outlet_Type, COUNT(DISTINCT Item_Identifier) AS Purchased
    FROM blinkit_data
    WHERE Total_Sales > 100
    GROUP BY Outlet_Type
),
RepeatBuyers AS (
    SELECT Outlet_Type, COUNT(DISTINCT Item_Identifier) AS RepeatBuyers
    FROM blinkit_data
    WHERE Total_Sales > (SELECT AVG(Total_Sales) FROM blinkit_data)
    GROUP BY Outlet_Type
),
HighRated AS (
    SELECT Outlet_Type, COUNT(DISTINCT Item_Identifier) AS HighRated
    FROM blinkit_data
    WHERE Rating >= 4.5
    GROUP BY Outlet_Type
)
SELECT
    f.Outlet_Type,
    f.Listed,
    v.Visible,
    p.Purchased,
    r.RepeatBuyers,
    h.HighRated
FROM Funnel f
JOIN Visible v ON f.Outlet_Type = v.Outlet_Type
JOIN Purchased p ON f.Outlet_Type = p.Outlet_Type
JOIN RepeatBuyers r ON f.Outlet_Type = r.Outlet_Type
JOIN HighRated h ON f.Outlet_Type = h.Outlet_Type
ORDER BY f.Outlet_Type;
