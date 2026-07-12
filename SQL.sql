 use PortfolioProject_MarketingAnalytics
SELECT TOP 40 * FROM customer_journey;
SELECT TOP 20 * FROM engagement_data;
SELECT TOP 20 * FROM customer_reviews;
SELECT TOP 20 * FROM customers;
SELECT TOP 20 * FROM products;
SELECT TOP 20 * FROM geography;


--- EDA 
--detect no od rows and coulmns for each table 
SELECT 'customer_journey' AS TableName, COUNT(*) AS RowsCount, 7 AS ColumnsCount FROM customer_journey
UNION ALL
SELECT 'customer_reviews', COUNT(*), 6 FROM customer_reviews
UNION ALL
SELECT 'customers', COUNT(*), 7 FROM customers
UNION ALL
SELECT 'engagement_data', COUNT(*), 8 FROM engagement_data
UNION ALL
SELECT 'products', COUNT(*), 4 FROM products
UNION ALL
SELECT 'geography', COUNT(*), 3 FROM geography;

--check nulls
SELECT *
FROM (
    SELECT 'customer_journey' AS TableName, 'JourneyID' AS ColumnName, COUNT(*) - COUNT(JourneyID) AS NullCount FROM customer_journey
    UNION ALL SELECT 'customer_journey', 'CustomerID', COUNT(*) - COUNT(CustomerID) FROM customer_journey
    UNION ALL SELECT 'customer_journey', 'ProductID', COUNT(*) - COUNT(ProductID) FROM customer_journey
    UNION ALL SELECT 'customer_journey', 'VisitDate', COUNT(*) - COUNT(VisitDate) FROM customer_journey
    UNION ALL SELECT 'customer_journey', 'Stage', COUNT(*) - COUNT(Stage) FROM customer_journey
    UNION ALL SELECT 'customer_journey', 'Action', COUNT(*) - COUNT(Action) FROM customer_journey
    UNION ALL SELECT 'customer_journey', 'Duration', COUNT(*) - COUNT(Duration) FROM customer_journey

    UNION ALL SELECT 'engagement_data', 'EngagementID', COUNT(*) - COUNT(EngagementID) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'ContentID', COUNT(*) - COUNT(ContentID) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'ContentType', COUNT(*) - COUNT(ContentType) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'Likes', COUNT(*) - COUNT(Likes) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'EngagementDate', COUNT(*) - COUNT(EngagementDate) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'CampaignID', COUNT(*) - COUNT(CampaignID) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'ProductID', COUNT(*) - COUNT(ProductID) FROM engagement_data
    UNION ALL SELECT 'engagement_data', 'ViewsClicksCombined', COUNT(*) - COUNT(ViewsClicksCombined) FROM engagement_data

    UNION ALL SELECT 'customer_reviews', 'ReviewID', COUNT(*) - COUNT(ReviewID) FROM customer_reviews
    UNION ALL SELECT 'customer_reviews', 'CustomerID', COUNT(*) - COUNT(CustomerID) FROM customer_reviews
    UNION ALL SELECT 'customer_reviews', 'ProductID', COUNT(*) - COUNT(ProductID) FROM customer_reviews
    UNION ALL SELECT 'customer_reviews', 'ReviewDate', COUNT(*) - COUNT(ReviewDate) FROM customer_reviews
    UNION ALL SELECT 'customer_reviews', 'Rating', COUNT(*) - COUNT(Rating) FROM customer_reviews
    UNION ALL SELECT 'customer_reviews', 'ReviewText', COUNT(*) - COUNT(ReviewText) FROM customer_reviews

    UNION ALL SELECT 'customers', 'CustomerID', COUNT(*) - COUNT(CustomerID) FROM customers
    UNION ALL SELECT 'customers', 'CustomerName', COUNT(*) - COUNT(CustomerName) FROM customers
    UNION ALL SELECT 'customers', 'Email', COUNT(*) - COUNT(Email) FROM customers
    UNION ALL SELECT 'customers', 'Gender', COUNT(*) - COUNT(Gender) FROM customers
    UNION ALL SELECT 'customers', 'Age', COUNT(*) - COUNT(Age) FROM customers
    UNION ALL SELECT 'customers', 'GeographyID', COUNT(*) - COUNT(GeographyID) FROM customers

    UNION ALL SELECT 'products', 'ProductID', COUNT(*) - COUNT(ProductID) FROM products
    UNION ALL SELECT 'products', 'ProductName', COUNT(*) - COUNT(ProductName) FROM products
    UNION ALL SELECT 'products', 'Category', COUNT(*) - COUNT(Category) FROM products
    UNION ALL SELECT 'products', 'Price', COUNT(*) - COUNT(Price) FROM products

    UNION ALL SELECT 'geography', 'GeographyID', COUNT(*) - COUNT(GeographyID) FROM geography
    UNION ALL SELECT 'geography', 'Country', COUNT(*) - COUNT(Country) FROM geography
    UNION ALL SELECT 'geography', 'City', COUNT(*) - COUNT(City) FROM geography
) t
WHERE NullCount > 0;

-- check duplicates  on each roch not only pk 
SELECT 'customer_journey' AS TableName, COUNT(*) AS TotalDuplicates
FROM (
    SELECT JourneyID, CustomerID, ProductID, VisitDate, Stage, Action, Duration, COUNT(*) AS DupCount
    FROM customer_journey
    GROUP BY JourneyID, CustomerID, ProductID, VisitDate, Stage, Action, Duration
    HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'engagement_data', COUNT(*)
FROM (
    SELECT EngagementID, ContentID, ContentType, Likes, EngagementDate, CampaignID, ProductID, ViewsClicksCombined, COUNT(*) AS DupCount
    FROM engagement_data
    GROUP BY EngagementID, ContentID, ContentType, Likes, EngagementDate, CampaignID, ProductID, ViewsClicksCombined
    HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'customer_reviews', COUNT(*)
FROM (
    SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText, COUNT(*) AS DupCount
    FROM customer_reviews
    GROUP BY ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText
    HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'customers', COUNT(*)
FROM (
    SELECT CustomerID, CustomerName, Email, Gender, Age, GeographyID, COUNT(*) AS DupCount
    FROM customers
    GROUP BY CustomerID, CustomerName, Email, Gender, Age, GeographyID
    HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'products', COUNT(*)
FROM (
    SELECT ProductID, ProductName, Category, Price, COUNT(*) AS DupCount
    FROM products
    GROUP BY ProductID, ProductName, Category, Price
    HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'geography', COUNT(*)
FROM (
    SELECT GeographyID, Country, City, COUNT(*) AS DupCount
    FROM geography
    GROUP BY GeographyID, Country, City
    HAVING COUNT(*) > 1
) t;

--check standrization
--- customer journy 
SELECT 
    [Stage] COLLATE Latin1_General_CS_AS AS StageValue,
    COUNT(*) AS Frequency
FROM customer_journey
GROUP BY [Stage] COLLATE Latin1_General_CS_AS
ORDER BY Frequency DESC;
SELECT 
    [ContentType] COLLATE Latin1_General_CS_AS AS ContentTypeValue,
    COUNT(*) AS Frequency
FROM engagement_data
GROUP BY [ContentType] COLLATE Latin1_General_CS_AS
ORDER BY Frequency DESC;


--- create views and clean
--- fill nulls in duration

SELECT 
    AVG(Price) AS Average_Value,
    MIN(Price) AS Minimum_Value,
    MAX(Price) AS Maximum_Value
FROM 
    dbo.Products
WHERE 
    Price BETWEEN 10 AND 300;
	GO

	GO
CREATE OR ALTER VIEW vw_clean_journey AS
SELECT
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    UPPER(LTRIM(RTRIM([Stage]))) AS CleanStage,
    [Action],
    ISNULL(
        Duration,
        (SELECT AVG(Duration)
         FROM customer_journey
         WHERE Duration IS NOT NULL)
    ) AS CleanDuration
FROM customer_journey;
GO
SELECT TOP 1000*
FROM vw_clean_journey ;

GO
CREATE OR ALTER VIEW vw_clean_engagement_data AS
SELECT
    EngagementID,
    ContentID,
    UPPER(LTRIM(RTRIM(ContentType))) AS CleanContentType,
    Likes,
    EngagementDate,
    CampaignID,
    ProductID,
    ViewsClicksCombined
FROM engagement_data;
GO
SELECT TOP 1000*
FROM vw_clean_engagement_data;

GO
CREATE OR ALTER VIEW vw_stage_engagement AS
SELECT
    cj.JourneyID,
    cj.CustomerID,
    cj.ProductID,
    cj.VisitDate,
    cj.CleanStage,
    cj.Action,
    cj.CleanDuration,
    ed.EngagementID,
    ed.ContentID,
    ed.CleanContentType,
    ed.Likes,
    ed.EngagementDate,
    ed.CampaignID,
    ed.ProductID AS EngagementProductID,
    ed.ViewsClicksCombined
FROM vw_clean_journey cj
LEFT JOIN vw_clean_engagement_data ed
    ON cj.ProductID = ed.ProductID;
GO
SELECT TOP 1000*
FROM vw_stage_engagement;

GO
CREATE OR ALTER VIEW vw_final_clean_journey AS
WITH RankedData AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate
            ORDER BY JourneyID
        ) AS rn
    FROM vw_stage_engagement
)
SELECT
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    CleanStage,
    Action,
    CleanDuration,
    EngagementID,
    ContentID,
    CleanContentType,
    Likes,
    EngagementDate,
    CampaignID,
    EngagementProductID,
    ViewsClicksCombined
FROM RankedData
WHERE rn = 1;
GO

SELECT TOP 1000*
FROM vw_final_clean_journey ;

-- نمل تشيك على التكرارات   بعد ما شلناها 
SELECT
    CustomerID,
    ProductID,
    VisitDate,
    COUNT(*) AS DuplicateCount
FROM vw_final_clean_journey
GROUP BY CustomerID, ProductID, VisitDate
HAVING COUNT(*) > 1; 

GO
CREATE OR ALTER VIEW vw_customers AS
SELECT *
FROM customers;
GO

GO
CREATE OR ALTER VIEW vw_products AS
SELECT *
FROM products;
GO

GO
CREATE OR ALTER VIEW vw_customer_reviews AS
SELECT *
FROM customer_reviews;
GO

GO
CREATE OR ALTER VIEW vw_geography AS
SELECT *
FROM geography;
GO
