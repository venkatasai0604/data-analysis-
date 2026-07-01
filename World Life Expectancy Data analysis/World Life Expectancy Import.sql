
USE Portfolio
GO

-- ==========================================================
-- STEP 1: Create Tables
-- ==========================================================

DROP TABLE IF EXISTS dbo.LifeExpectancyData
CREATE TABLE dbo.LifeExpectancyData
(
    Country                nvarchar(100),
    Year                   int,
    Status                 nvarchar(50),
    Life_expectancy        float,
    Adult_Mortality        float,
    infant_deaths          int,
    under_five_deaths      int,
    HIV_AIDS                float,
    Measles                int,
    Polio                  float,
    Diphtheria             float,
    Hepatitis_B            float,
    BMI                    float,
    thinness_1_19_years    float,
    thinness_5_9_years     float
)

DROP TABLE IF EXISTS dbo.CountryEconomyData
CREATE TABLE dbo.CountryEconomyData
(
    Country                             nvarchar(100),
    Year                                int,
    Alcohol                             float,
    percentage_expenditure              float,
    Total_expenditure                   float,
    GDP                                 float,
    Population                          float,
    Income_composition_of_resources     float,
    Schooling                           float
)
GO

-- ==========================================================
-- STEP 2: Bulk Insert
-- ==========================================================

BULK INSERT dbo.LifeExpectancyData
FROM 'C:\Imports\LifeExpectancyData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',   
    TABLOCK
)

BULK INSERT dbo.CountryEconomyData
FROM 'C:\Imports\CountryEconomyData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)
GO

-- ==========================================================
--  Sanity checks (row counts + spot check nulls)
-- ==========================================================

SELECT COUNT(*) AS LifeExpectancyRowCount FROM dbo.LifeExpectancyData
SELECT COUNT(*) AS CountryEconomyRowCount FROM dbo.CountryEconomyData

SELECT * FROM dbo.LifeExpectancyData WHERE Country IS NULL
SELECT * FROM dbo.CountryEconomyData WHERE Country IS NULL


