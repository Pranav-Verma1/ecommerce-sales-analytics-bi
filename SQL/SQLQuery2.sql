USE ECommerceSalesAnalyticsBI;
GO

-- =========================
-- STAGING: ORDERS
-- =========================
CREATE TABLE stg_orders (
    Order_ID BIGINT,
    Order_Date DATE,
    Customer_ID INT,
    Product_ID INT,
    Carrier_ID VARCHAR(20),
    Quantity INT,
    Shipping_Cost DECIMAL(10,2),
    Order_Status VARCHAR(50)
);

-- =========================
-- STAGING: CUSTOMERS
-- =========================
CREATE TABLE stg_customers (
    Customer_ID INT,
    Customer_Name VARCHAR(255),
    Gender VARCHAR(20),
    City VARCHAR(255),
    State VARCHAR(255)
);

-- =========================
-- STAGING: PRODUCTS
-- =========================
CREATE TABLE stg_products (
    Product_ID INT,
    Product_Name VARCHAR(255),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100),
    Base_Cost DECIMAL(10,2),
    Unit_Price DECIMAL(10,2)
);

-- =========================
-- STAGING: CARRIERS
-- =========================
CREATE TABLE stg_carriers (
    Carrier_ID VARCHAR(20),
    Carrier_Name VARCHAR(100),
    Ship_Mode VARCHAR(50),
    Avg_Delivery_Days INT
);
GO

-- =========================
-- ETL Log table
-- =========================


CREATE TABLE etl_log (
    Log_ID INT IDENTITY(1,1),
    Process_Name VARCHAR(100),
    Rows_Loaded INT,
    Load_Time DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20))
    go

 CREATE TABLE etl_file_tracking
(
    File_Name VARCHAR(200) PRIMARY KEY,
    Last_Modified DATETIME,
    Last_Loaded DATETIME,
    Status VARCHAR(20)
);

CREATE TABLE dim_customers
(
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(200),
    Gender VARCHAR(20),
    City VARCHAR(100),
    State VARCHAR(100)
);

CREATE TABLE dim_products
(
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(200),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100),
    Base_Cost DECIMAL(10,2),
    Unit_Price DECIMAL(10,2)
);

CREATE TABLE dim_carriers
(
    Carrier_ID VARCHAR(20) PRIMARY KEY,
    Carrier_Name VARCHAR(100),
    Ship_Mode VARCHAR(50),
    Avg_Delivery_Days INT
);

CREATE TABLE dim_date
(
    Date_Key INT PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Quarter INT,
    Month_Number INT,
    Month_Name VARCHAR(20),
    Day_Number INT,
    Day_Name VARCHAR(20)
);

CREATE TABLE fact_sales
(
    Order_ID BIGINT,
    Order_Date DATE,
    Customer_ID INT,
    Product_ID INT,
    Carrier_ID VARCHAR(20),
    Quantity INT,
    Shipping_Cost DECIMAL(10,2),
    Order_Status VARCHAR(50)
);


INSERT INTO dim_customers
SELECT DISTINCT
    Customer_ID,
    Customer_Name,
    Gender,
    City,
    State
FROM stg_customers;

INSERT INTO dim_products
SELECT DISTINCT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    Base_Cost,
    Unit_Price
FROM stg_products;

INSERT INTO dim_carriers
SELECT DISTINCT
    Carrier_ID,
    Carrier_Name,
    Ship_Mode,
    Avg_Delivery_Days
FROM stg_carriers;

INSERT INTO fact_sales
(
    Order_ID,
    Order_Date,
    Customer_ID,
    Product_ID,
    Carrier_ID,
    Quantity,
    Shipping_Cost,
    Order_Status
)W
SELECT
    Order_ID,
    Order_Date,
    Customer_ID,
    Product_ID,
    Carrier_ID,
    Quantity,
    Shipping_Cost,
    Order_Status
FROM stg_orders;
GO

CREATE OR ALTER PROCEDURE sp_refresh_dim_customers
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO dim_customers
    (
        Customer_ID,
        Customer_Name,
        Gender,
        City,
        State
    )
    SELECT DISTINCT
        Customer_ID,
        Customer_Name,
        Gender,
        City,
        State
    FROM stg_customers;

END
GO

CREATE OR ALTER PROCEDURE sp_refresh_dim_products
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO dim_products
    SELECT DISTINCT
        Product_ID,
        Product_Name,
        Category,
        Sub_Category,
        Base_Cost,
        Unit_Price
    FROM stg_products;

END
GO

CREATE OR ALTER PROCEDURE sp_refresh_dim_carriers
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO dim_carriers
    SELECT DISTINCT
        Carrier_ID,
        Carrier_Name,
        Ship_Mode,
        Avg_Delivery_Days
    FROM stg_carriers;

END
GO


CREATE OR ALTER PROCEDURE sp_refresh_fact_sales
AS
BEGIN

    SET NOCOUNT ON;
    INSERT INTO fact_sales
    (
        Order_ID,
        Order_Date,
        Customer_ID,
        Product_ID,
        Carrier_ID,
        Quantity,
        Shipping_Cost,
        Order_Status
    )
    SELECT
        Order_ID,
        Order_Date,
        Customer_ID,
        Product_ID,
        Carrier_ID,
        Quantity,
        Shipping_Cost,
        Order_Status
    FROM stg_orders;

END
GO

CREATE OR ALTER PROCEDURE sp_refresh_warehouse
AS
BEGIN

    SET NOCOUNT ON;

    DELETE FROM fact_sales;
    DELETE FROM dim_customers;
    DELETE FROM dim_products;
    DELETE FROM dim_carriers;

    EXEC sp_refresh_dim_customers;
    EXEC sp_refresh_dim_products;
    EXEC sp_refresh_dim_carriers;
    EXEC sp_refresh_fact_sales;

END
GO

CREATE VIEW vw_sales_detail
AS
SELECT

    f.Order_ID,
    f.Order_Date,

    d.Year,
    d.Quarter,
    d.Month_Number,
    d.Month_Name,

    c.Customer_ID,
    c.Customer_Name,
    c.Gender,
    c.City,
    c.State,

    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,

    cr.Carrier_Name,
    cr.Ship_Mode,

    f.Quantity,
    p.Unit_Price,
    p.Base_Cost,

    (f.Quantity * p.Unit_Price) AS Revenue,

    (f.Quantity * p.Base_Cost) AS Cost,

    ((f.Quantity * p.Unit_Price)
      -
     (f.Quantity * p.Base_Cost)) AS Profit,

    f.Shipping_Cost,
    f.Order_Status

FROM fact_sales f

INNER JOIN dim_customers c
    ON f.Customer_ID = c.Customer_ID

INNER JOIN dim_products p
    ON f.Product_ID = p.Product_ID

INNER JOIN dim_carriers cr
    ON f.Carrier_ID = cr.Carrier_ID

INNER JOIN dim_date d
    ON f.Order_Date = d.Full_Date;




CREATE VIEW vw_daily_sales
AS
SELECT

    f.Order_Date,

    COUNT(DISTINCT f.Order_ID) AS Orders,

    SUM(f.Quantity) AS Units_Sold,

    SUM(f.Quantity * p.Unit_Price) AS Revenue,

    SUM(f.Quantity * p.Base_Cost) AS Cost,

    SUM(
        (f.Quantity * p.Unit_Price)
        -
        (f.Quantity * p.Base_Cost)
    ) AS Profit

FROM fact_sales f

INNER JOIN dim_products p
    ON f.Product_ID = p.Product_ID

GROUP BY f.Order_Date;



CREATE VIEW vw_monthly_sales
AS
SELECT

    d.Year,
    d.Month_Number,
    d.Month_Name,

    SUM(f.Quantity * p.Unit_Price) AS Revenue,

    SUM(
        (f.Quantity * p.Unit_Price)
        -
        (f.Quantity * p.Base_Cost)
    ) AS Profit,

    COUNT(DISTINCT f.Order_ID) AS Orders

FROM fact_sales f

INNER JOIN dim_products p
    ON f.Product_ID = p.Product_ID

INNER JOIN dim_date d
    ON f.Order_Date = d.Full_Date

GROUP BY
    d.Year,
    d.Month_Number,
    d.Month_Name;



CREATE VIEW vw_top_products
AS
SELECT

    p.Product_ID,
    p.Product_Name,
    p.Category,

    SUM(f.Quantity) AS Units_Sold,

    SUM(f.Quantity * p.Unit_Price) AS Revenue,

    SUM(
        (f.Quantity * p.Unit_Price)
        -
        (f.Quantity * p.Base_Cost)
    ) AS Profit

FROM fact_sales f

INNER JOIN dim_products p
    ON f.Product_ID = p.Product_ID

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category;


WITH DateSeries AS
(
    SELECT CAST('2023-01-01' AS DATE) AS Full_Date

    UNION ALL

    SELECT DATEADD(DAY, 1, Full_Date)
    FROM DateSeries
    WHERE Full_Date < '2025-12-31'
)

INSERT INTO dim_date
(
    Date_Key,
    Full_Date,
    Year,
    Quarter,
    Month_Number,
    Month_Name,
    Day_Number,
    Day_Name
)
SELECT

    CAST(FORMAT(Full_Date, 'yyyyMMdd') AS INT),

    Full_Date,

    YEAR(Full_Date),

    DATEPART(QUARTER, Full_Date),

    MONTH(Full_Date),

    DATENAME(MONTH, Full_Date),

    DAY(Full_Date),

    DATENAME(WEEKDAY, Full_Date)

FROM DateSeries
OPTION (MAXRECURSION 0);

SELECT COUNT(*)
FROM fact_sales f
INNER JOIN dim_date d
    ON f.Order_Date = d.Full_Date;
-- 0

SELECT COUNT(*)
FROM dim_date;


ALTER TABLE fact_sales
ADD CONSTRAINT FK_fact_customer
FOREIGN KEY (Customer_ID)
REFERENCES dim_customers(Customer_ID);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_fact_product
FOREIGN KEY (Product_ID)
REFERENCES dim_products(Product_ID);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_fact_carrier
FOREIGN KEY (Carrier_ID)
REFERENCES dim_carriers(Carrier_ID);



INSERT INTO etl_file_tracking
(
    File_Name,
    Last_Modified,
    Last_Loaded,
    Status
)
VALUES
('fact_orders.csv', NULL, NULL, 'NEW'),
('dim_customers.csv', NULL, NULL, 'NEW'),
('dim_products.csv', NULL, NULL, 'NEW'),
('dim_carriers.csv', NULL, NULL, 'NEW');