/*
World Life Expectancy Data Exploration


Tables:
  dbo.LifeExpectancyData   (Country, Year, Status, Life_expectancy, Adult_Mortality, infant_deaths,
                             under_five_deaths, HIV_AIDS, Measles, Polio, Diphtheria, Hepatitis_B,
                             BMI, thinness_1_19_years, thinness_5_9_years)
  dbo.CountryEconomyData   (Country, Year, Alcohol, percentage_expenditure, Total_expenditure,
                             GDP, Population, Income_composition_of_resources, Schooling)

Join key: Country + Year   (equivalent to location + date in the COVID project)
*/

USE Portfolio
GO


-- Select Data that we are going to be starting with

Select Country, Year, Status, Life_expectancy, Adult_Mortality
From dbo.LifeExpectancyData
order by 1,2


-- Adult Mortality vs Life Expectancy
-- Shows how mortality rate relates to overall life expectancy per country/year

Select Country, Year, Life_expectancy, Adult_Mortality,
       (Adult_Mortality / NULLIF(Life_expectancy,0)) * 100 as MortalityToLifeExpectancyRatio
From dbo.LifeExpectancyData
Where Country like '%India%'
order by 1,2


-- GDP vs Life Expectancy
-- Shows whether wealthier countries trend toward higher life expectancy

Select led.Country, led.Year, led.Life_expectancy, ced.GDP
From dbo.LifeExpectancyData led
Join dbo.CountryEconomyData ced
    On led.Country = ced.Country
    and led.Year = ced.Year
--Where led.Country like '%India%'
order by 1,2


-- Countries with Lowest Life Expectancy (worst-affected, analogous to Highest Infection Rate)

Select Country, MIN(Life_expectancy) as LowestLifeExpectancy, MAX(Life_expectancy) as HighestLifeExpectancy
From dbo.LifeExpectancyData
Group by Country
order by LowestLifeExpectancy asc


-- Countries with Highest Adult Mortality (analogous to Highest Death Count)

Select Country, MAX(Adult_Mortality) as HighestAdultMortality
From dbo.LifeExpectancyData
Where Adult_Mortality is not null
Group by Country
order by HighestAdultMortality desc



-- BREAKING THINGS DOWN BY DEVELOPMENT STATUS
-- (Status takes the place of "continent" in the COVID script - no continent column here)

-- Average life expectancy by Developed vs Developing status

Select Status, AVG(Life_expectancy) as AvgLifeExpectancy, AVG(Adult_Mortality) as AvgAdultMortality
From dbo.LifeExpectancyData
Where Life_expectancy is not null
Group by Status
order by AvgLifeExpectancy desc



-- GLOBAL NUMBERS

Select Year, AVG(Life_expectancy) as GlobalAvgLifeExpectancy, AVG(Adult_Mortality) as GlobalAvgAdultMortality
From dbo.LifeExpectancyData
Where Life_expectancy is not null
Group by Year
order by Year



-- Life Expectancy vs Schooling and Income Composition
-- Shows Country, Year, Life Expectancy alongside Schooling with a rolling average of Schooling per country over time

Select led.Country, led.Year, led.Life_expectancy, ced.Schooling, ced.Income_composition_of_resources
, AVG(ced.Schooling) OVER (Partition by led.Country Order by led.Country, led.Year) as RollingAvgSchooling
From dbo.LifeExpectancyData led
Join dbo.CountryEconomyData ced
    On led.Country = ced.Country
    and led.Year = ced.Year
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query

With LifeVsSchooling (Country, Year, Life_expectancy, Schooling, Income_composition_of_resources, RollingAvgSchooling)
as
(
Select led.Country, led.Year, led.Life_expectancy, ced.Schooling, ced.Income_composition_of_resources
, AVG(ced.Schooling) OVER (Partition by led.Country Order by led.Country, led.Year) as RollingAvgSchooling
From dbo.LifeExpectancyData led
Join dbo.CountryEconomyData ced
    On led.Country = ced.Country
    and led.Year = ced.Year
--order by 1,2
)
Select *, (RollingAvgSchooling / NULLIF(Life_expectancy,0)) * 100 as SchoolingToLifeExpectancyRatio
From LifeVsSchooling



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #RollingSchoolingLifeExpectancy
Create Table #RollingSchoolingLifeExpectancy
(
Country nvarchar(100),
Year int,
Life_expectancy float,
Schooling float,
Income_composition_of_resources float,
RollingAvgSchooling float
)

Insert into #RollingSchoolingLifeExpectancy
Select led.Country, led.Year, led.Life_expectancy, ced.Schooling, ced.Income_composition_of_resources
, AVG(ced.Schooling) OVER (Partition by led.Country Order by led.Country, led.Year) as RollingAvgSchooling
From dbo.LifeExpectancyData led
Join dbo.CountryEconomyData ced
    On led.Country = ced.Country
    and led.Year = ced.Year

Select *, (RollingAvgSchooling / NULLIF(Life_expectancy,0)) * 100 as SchoolingToLifeExpectancyRatio
From #RollingSchoolingLifeExpectancy



-- Creating View to store data for later visualizations (Tableau / Power BI)

Create View LifeExpectancyVsSchooling as
Select led.Country, led.Year, led.Status, led.Life_expectancy, led.Adult_Mortality,
       ced.GDP, ced.Population, ced.Schooling, ced.Income_composition_of_resources
, AVG(ced.Schooling) OVER (Partition by led.Country Order by led.Country, led.Year) as RollingAvgSchooling
From dbo.LifeExpectancyData led
Join dbo.CountryEconomyData ced
    On led.Country = ced.Country
    and led.Year = ced.Year
where led.Life_expectancy is not null
