/*

Cleaning Data in SQL Queries - World Life Expectancy Data

Tables: dbo.LifeExpectancyData, dbo.CountryEconomyData
Mirrors the Nashville Housing cleaning project structure

*/


Select *
From Portfolio.dbo.LifeExpectancyData

Select *
From Portfolio.dbo.CountryEconomyData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize the Status field (trim whitespace, fix casing)


Select Distinct(Status)
From Portfolio.dbo.LifeExpectancyData


Select Status, LTRIM(RTRIM(Status))
From Portfolio.dbo.LifeExpectancyData


Update LifeExpectancyData
SET Status = LTRIM(RTRIM(Status))


-- If it doesn't Update properly

ALTER TABLE LifeExpectancyData
Add StatusStandardized Nvarchar(50);

Update LifeExpectancyData
SET StatusStandardized = LTRIM(RTRIM(Status))


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Missing GDP data
-- GDP for a given country doesn't swing wildly year to year, so fill nulls
-- using another year's GDP figure for the same country


Select a.Country, a.Year, a.GDP, b.Country, b.Year, b.GDP, ISNULL(a.GDP, b.GDP)
From Portfolio.dbo.CountryEconomyData a
JOIN Portfolio.dbo.CountryEconomyData b
	on a.Country = b.Country
	AND a.Year <> b.Year
Where a.GDP is null
and b.GDP is not null


Update a
SET GDP = ISNULL(a.GDP, b.GDP)
From Portfolio.dbo.CountryEconomyData a
JOIN Portfolio.dbo.CountryEconomyData b
	on a.Country = b.Country
	AND a.Year <> b.Year
Where a.GDP is null
and b.GDP is not null



-- Populate Missing Population data (same logic as GDP)


Select a.Country, a.Year, a.Population, b.Country, b.Year, b.Population, ISNULL(a.Population, b.Population)
From Portfolio.dbo.CountryEconomyData a
JOIN Portfolio.dbo.CountryEconomyData b
	on a.Country = b.Country
	AND a.Year <> b.Year
Where a.Population is null
and b.Population is not null


Update a
SET Population = ISNULL(a.Population, b.Population)
From Portfolio.dbo.CountryEconomyData a
JOIN Portfolio.dbo.CountryEconomyData b
	on a.Country = b.Country
	AND a.Year <> b.Year
Where a.Population is null
and b.Population is not null




--------------------------------------------------------------------------------------------------------------------------

-- Flagging Impossible / Placeholder Values
-- A Life_expectancy or Adult_Mortality of 0 is a data entry issue, not a real value
-- Setting these to NULL so they don't distort averages downstream


Select Country, Year, Life_expectancy, Adult_Mortality
From Portfolio.dbo.LifeExpectancyData
Where Life_expectancy = 0 or Adult_Mortality = 0


Update LifeExpectancyData
SET Life_expectancy = NULL
Where Life_expectancy = 0

Update LifeExpectancyData
SET Adult_Mortality = NULL
Where Adult_Mortality = 0



Select *
From Portfolio.dbo.LifeExpectancyData



--------------------------------------------------------------------------------------------------------------------------

-- Change Status values to a consistent Yes/No style flag: Is_Developed


Select Distinct(Status), Count(Status)
From Portfolio.dbo.LifeExpectancyData
Group by Status
order by 2


Select Status
, CASE When Status = 'Developed' THEN 'Yes'
	   When Status = 'Developing' THEN 'No'
	   ELSE Status
	   END as Is_Developed
From Portfolio.dbo.LifeExpectancyData


ALTER TABLE LifeExpectancyData
Add Is_Developed Nvarchar(10);

Update LifeExpectancyData
SET Is_Developed = CASE When Status = 'Developed' THEN 'Yes'
	   When Status = 'Developing' THEN 'No'
	   ELSE Status
	   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- A Country should only appear once per Year - flag any repeats


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY Country,
				 Year
				 ORDER BY
					Country
					) row_num

From Portfolio.dbo.LifeExpectancyData
--order by Country
)
Select *
From RowNumCTE
Where row_num > 1
Order by Country


-- Repeat the same check on CountryEconomyData

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY Country,
				 Year
				 ORDER BY
					Country
					) row_num

From Portfolio.dbo.CountryEconomyData
)
Select *
From RowNumCTE
Where row_num > 1
Order by Country



Select *
From Portfolio.dbo.LifeExpectancyData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Drop the original Status column now that Is_Developed / StatusStandardized replace it
-- (Only run this after confirming the new columns look correct)


Select *
From Portfolio.dbo.LifeExpectancyData


-- ALTER TABLE Portfolio.dbo.LifeExpectancyData
-- DROP COLUMN Status, StatusStandardized

















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE Portfolio

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE Portfolio;
--GO
--BULK INSERT LifeExpectancyData FROM 'C:\Imports\LifeExpectancyData.csv'
--   WITH (
--      FIRSTROW = 2,
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE Portfolio;
--GO
--SELECT * INTO LifeExpectancyData
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Imports\LifeExpectancyData.csv', [Sheet1$]);
--GO
