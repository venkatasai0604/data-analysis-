# World Life Expectancy — SQL Data Cleaning & Exploration Project

A SQL Server portfolio project analyzing WHO/Kaggle life expectancy data across 193 countries (2000–2015). The project covers data cleaning, exploratory analysis, and view creation for downstream visualization — structured around a two-table relational design (health metrics + economic/social metrics) joined on `Country + Year`.

## 📊 Dataset

Source: [WHO Life Expectancy Dataset](https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who) (Kaggle), originally compiled from the WHO Global Health Observatory and UN data repositories.

- **2,938 rows** across **193 countries**, **2000–2015**
- Split into two related tables for a relational (join-based) workflow:

| Table | Description |
|---|---|
| `dbo.LifeExpectancyData` | Country, Year, Status, Life expectancy, Adult Mortality, infant/under-five deaths, HIV/AIDS, Measles, Polio, Diphtheria, Hepatitis B, BMI, thinness indicators |
| `dbo.CountryEconomyData` | Country, Year, Alcohol consumption, expenditure, GDP, Population, Income composition of resources, Schooling |

Join key: **`Country + Year`**

## 🗂️ Files in this Repository

| File | Purpose |
|---|---|
| `World Life Expectancy Import.sql` | Creates the two tables and bulk-inserts the raw CSV data into SQL Server |
| `World Life Expectancy Data Cleaning.sql` | Cleans the raw data — standardizes fields, fills missing GDP/Population via self-join, flags invalid zero-values, deduplicates, adds an `Is_Developed` flag |
| `World Life Expectancy Data Exploration.sql` | Exploratory queries — mortality ratios, GDP vs. life expectancy, rolling averages, CTEs, temp tables, and a final view for BI tools |
| `LifeExpectancyData.csv` / `CountryEconomyData.csv` | Cleaned, split source data ready for import |

## 🛠️ Tools Used

- **SQL Server Management Studio (SSMS)** — data import, cleaning, and querying
- **T-SQL** — joins, CTEs, temp tables, window functions, views
- *(Optional next step)* Tableau / Power BI for visualization of the final view

## 🔧 Skills Demonstrated

- **Data Import**: `BULK INSERT`, data type planning, handling CSV header rows
- **Data Cleaning**: Self-joins to fill missing values, standardizing text fields, flagging bad/placeholder data (zero-values), deduplication via `ROW_NUMBER() OVER (PARTITION BY ...)`
- **Data Exploration**: Aggregate functions, ratio/derived metrics, `JOIN`s across related tables
- **Window Functions**: Rolling averages via `OVER (PARTITION BY ... ORDER BY ...)`
- **CTEs & Temp Tables**: Two alternative approaches for reusing a windowed calculation in further arithmetic
- **Views**: Created a reusable view (`LifeExpectancyVsSchooling`) for visualization tools

## 🚀 How to Run

1. Create a database named `Portfolio` in SQL Server (or update the `USE` statement in each script to match your database name).
2. Save `LifeExpectancyData.csv` and `CountryEconomyData.csv` locally and update the file paths in `World_Life_Expectancy_Import.sql`.
3. Run the scripts in this order:
   1. `World_Life_Expectancy_Import.sql`
   2. `World_Life_Expectancy_Data_Cleaning.sql`
   3. `World_Life_Expectancy_Data_Exploration.sql`

## 📈 Example Insights Explored

- Relationship between Adult Mortality and Life Expectancy
- Relationship between GDP and Life Expectancy
- Countries with the lowest life expectancy / highest adult mortality
- Average life expectancy split by Developed vs. Developing status
- Global life expectancy trend from 2000–2015
- Rolling average of Schooling per country over time, related back to life expectancy

## ⚠️ Data Limitations

- GDP, Population, Hepatitis B, and a few other fields contain real missing values in the source data — some were imputed via self-join (using another year's value for the same country) where possible, but countries missing a field across *every* year remain null.
- The dataset only covers 2000–2015, so it doesn't reflect more recent trends.

## 🙋 Author

venkata Sai — CSE student, IIIT Sri City. Built as part of an ongoing series of SQL portfolio projects .
