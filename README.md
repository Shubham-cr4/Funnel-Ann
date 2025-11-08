Funnel Analysis (SQL Project)
📘 Project Overview

This project performs an end-to-end Funnel and Sales Performance Analysis on Blinkit’s sales dataset using SQL.
The goal is to clean, analyze, and extract business insights from item-level and outlet-level data, identifying sales patterns, conversion rates, and performance across outlets.

🧩 Objectives

Data Cleaning & Preprocessing

Standardize inconsistent entries in categorical columns (e.g., Item_Fat_Content).

Identify duplicate records and validate data integrity.

Descriptive Analysis

Calculate total, average, and item-wise sales.

Derive KPIs such as average rating, item visibility, and outlet performance.

Sales Performance Analysis

Evaluate sales contribution by item type, fat content, and outlet attributes.

Rank top-selling items and outlets.

Funnel Analysis

Track item flow from Listed → Visible → Purchased → Repeat Buyers → High Rated.

Compute stage-wise conversion rates.

Compare funnel performance across different Outlet Types.

🧹 Data Cleaning
UPDATE blinkit_data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;


✔ Standardized Item_Fat_Content values
✔ Verified with SELECT DISTINCT Item_Fat_Content FROM blinkit_data;

📊 Key Analyses
1️⃣ Basic KPIs

Total Sales (in Millions)

Average Sales

Total Orders

Average Rating

SELECT CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million FROM blinkit_data;
SELECT CAST(AVG(Total_Sales) AS INT) AS Avg_Sales FROM blinkit_data;
SELECT COUNT(*) AS No_of_Orders FROM blinkit_data;
SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating FROM blinkit_data;

2️⃣ Sales by Dimensions
🔹 By Item Type
SELECT Item_Type, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;

🔹 By Fat Content
SELECT Item_Fat_Content, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content;

🔹 By Outlet Establishment Year
SELECT Outlet_Establishment_Year, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;

🔹 By Outlet Size
SELECT Outlet_Size, 
       SUM(Total_Sales) AS Total_Sales,
       (SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

3️⃣ Outlet Performance Summary
SELECT Outlet_Type, 
       SUM(Total_Sales) AS Total_Sales,
       AVG(Total_Sales) AS Avg_Sales,
       COUNT(*) AS No_Of_Items,
       AVG(Rating) AS Avg_Rating,
       AVG(Item_Visibility) AS Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;


Insight: Helps identify which outlet types contribute most to sales and customer satisfaction.

4️⃣ Visibility & Rating Insights
🔹 By Visibility Buckets
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

🔹 Compare Ratings by Location
SELECT Outlet_Location_Type, AVG(Rating) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Avg_Rating DESC;

5️⃣ Top-N and Ranking Analysis
WITH RankedSales AS (
    SELECT Outlet_Type, Item_Identifier, SUM(Total_Sales) AS Total_Sales,
           RANK() OVER (PARTITION BY Outlet_Type ORDER BY SUM(Total_Sales) DESC) AS RankNo
    FROM blinkit_data
    GROUP BY Outlet_Type, Item_Identifier
)
SELECT * 
FROM RankedSales
WHERE RankNo <= 3;


Insight: Identifies the top 3 selling items per outlet type.

6️⃣ Funnel Analysis (Core KPI)

Funnel stages:

Listed → Visible → Purchased → Repeat Buyers → High Rated

WITH Funnel AS (...), Visible AS (...), Purchased AS (...),
     RepeatBuyers AS (...), HighRated AS (...)
SELECT Listed, Visible, Purchased, RepeatBuyers, HighRated
FROM Funnel, Visible, Purchased, RepeatBuyers, HighRated;

🔹 Conversion Rates Between Stages
SELECT
    CAST(100.0 * Visible / Listed AS DECIMAL(5,2)) AS Visibility_Rate,
    CAST(100.0 * Purchased / Visible AS DECIMAL(5,2)) AS Purchase_Rate,
    CAST(100.0 * RepeatBuyers / Purchased AS DECIMAL(5,2)) AS Repeat_Rate,
    CAST(100.0 * HighRated / RepeatBuyers AS DECIMAL(5,2)) AS Rating_Rate
FROM Funnel, Visible, Purchased, RepeatBuyers, HighRated;

🔹 Funnel by Outlet Type
WITH Funnel AS (...), Visible AS (...), Purchased AS (...),
     RepeatBuyers AS (...), HighRated AS (...)
SELECT
    f.Outlet_Type, f.Listed, v.Visible, p.Purchased, r.RepeatBuyers, h.HighRated
FROM Funnel f
JOIN Visible v ON f.Outlet_Type = v.Outlet_Type
JOIN Purchased p ON f.Outlet_Type = p.Outlet_Type
JOIN RepeatBuyers r ON f.Outlet_Type = r.Outlet_Type
JOIN HighRated h ON f.Outlet_Type = h.Outlet_Type
ORDER BY f.Outlet_Type;

📈 Insights & Learnings

Majority of sales come from Regular Fat items and Medium-sized outlets.

Outlet Type “Supermarket Type1” contributes the highest sales volume.

High visibility products consistently outperform low visibility ones.

Funnel analysis revealed a drop-off at the purchase and repeat stages, indicating opportunities for marketing and retention improvement.

🧠 Tech Stack

SQL Server / MySQL

Excel / Power BI (for visualization, optional)

Dataset: Blinkit Sales Data (1M+ rows)

🚀 Future Enhancements

Integrate with Power BI dashboards for visual funnel representation.

Add time-series forecasting for outlet sales trends.

Include customer segmentation for targeted insights.

🧾 Author

Shubham Kumar
📧 Data Analytics & SQL Enthusiast
💼 Project:  Funnel Analysis (SQL)
