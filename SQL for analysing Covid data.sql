@@ -3,6 +3,19 @@ CREATE DATABASE COVID
 USE COVID
 GO

 -- Before conducting data analysis, I usually check missing value or null value to make sure my data is full and avoid errors during analysis. Let's do it :))
 --CHECK NULL data
 SELECT * FROM dbo.Data
 WHERE Province IS NULL
 OR Country IS NULL
 OR Latitude IS NULL
 OR Longitude IS NULL
 OR Date IS NULL
 OR Confirmed IS NULL
 OR Deaths IS NULL
 OR Recovered IS NULL

 --Update null value = 0
 UPDATE dbo.Data 
 SET Longitude = 0 WHERE Longitude IS NULL

 @@ -11,28 +24,19 @@ SET Latitude = 0 WHERE Latitude IS NULL

 UPDATE dbo.Data
 SET Recovered = 0 WHERE Recovered IS NULL

 UPDATE dbo.Data
 SET Active = 0 WHERE Active IS NULL

 UPDATE dbo.Data
 SET Incidence_Rate = 0 WHERE Incidence_Rate IS NULL

 UPDATE dbo.Data
 SET Case_Fatality_Ratio = 0 WHERE Case_Fatality_Ratio IS NULL

 DELETE FROM dbo.Data WHERE MONTH(Date) = 8
 --- 1. DESCRIPTIVE STATISTICS ---
 ---- We will check some basic statistics before going to the indexs of 2 major characteristics of descriptive stastistics

 --CHECK NULL data
 SELECT * FROM dbo.Data
 WHERE Province IS NULL
 OR Country IS NULL
 OR Latitude IS NULL
 OR Longitude IS NULL
 OR Date IS NULL
 OR Confirmed IS NULL
 OR Deaths IS NULL
 OR Recovered IS NULL


 ---1. BASIC DESCRIPTIVE STATISTICS
 /* check first 10 rows */
 SELECT TOP 10 * FROM dbo.Data

 @@ -71,29 +75,62 @@ FROM dbo.Data
 GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
 ORDER BY 1,2

 --avg: confirmed, deaths, recovered per month
 -- The total case: confirmed, deaths, recovered per month

 SELECT DATEPART(YEAR, Date) AS 'Year', 
 	DATEPART(MONTH, Date) AS 'Month', 
 	ROUND(AVG(Confirmed),0) AS avg_confirmed,
 	ROUND(AVG(Deaths),0) AS avg_dealths, 
 	ROUND(AVG(Recovered),0) AS avg_recovered
 	sum(Confirmed) AS sum_confirmed, 
 	sum(Deaths) AS sum_dealths, 
 	sum(Recovered) AS sum_recovered
 FROM dbo.Data
 GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
 ORDER BY 1,2

 -- The total case: confirmed, deaths, recovered per month
 /********* 1.1. The central tendency: a distribution is an estimate of the “center” of a distribution of values: 
 -- MEAN
 -- MODE
 -- MEDIAN
 *********/

 ---------- MEAN ----------

 SELECT DATEPART(YEAR, Date) AS 'Year', 
 	DATEPART(MONTH, Date) AS 'Month', 
 	sum(Confirmed) AS sum_confirmed, 
 	sum(Deaths) AS sum_dealths, 
 	sum(Recovered) AS sum_recovered
 	ROUND(AVG(Confirmed),0) AS avg_confirmed,
 	ROUND(AVG(Deaths),0) AS avg_dealths, 
 	ROUND(AVG(Recovered),0) AS avg_recovered
 FROM dbo.Data
 GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
 ORDER BY 1,2

 /* How spread out? */
 ---------- MEDIAN ----------
 --To get the last value in the top 50 percent of rows.
 SELECT TOP 1 Confirmed
 FROM dbo.Data
 WHERE Confirmed IN (SELECT TOP 50 PERCENT Confirmed 
 					FROM dbo.Data
 					ORDER BY Confirmed ASC)
 ORDER BY Confirmed DESC

 ---------- MODE ----------
 /* What is the frequently occuring numbers of confirmed cases in each month? */
 /* we can see that February 2020 are the months which have most number of confirmed case*/
 SELECT TOP 1 
 	DATEPART(YEAR, Date) AS 'Year', 
 	DATEPART(MONTH, Date) AS 'Month', 
 	confirmed
 FROM   dbo.Data
 WHERE  Confirmed IS Not NULL
 GROUP  BY DATEPART(YEAR, Date), DATEPART(MONTH, Date), confirmed
 ORDER  BY COUNT(*) DESC

 /********* 1.2. The dispersion: refers to the spread of the values around the central tendency:
 -- RANGE = max value - min value
 -- VARIANCE
 -- STANDART DEVIATION
 *********/

 -- How spread out? 
 --- confirmed case
 SELECT 
 	SUM(confirmed) AS total_confirmed, 
 @@ -228,7 +265,7 @@ SELECT
 	PERCENTILE_DISC(0.95) WITHIN GROUP(ORDER BY confirmed) OVER() AS pct_95_disc_reconfirmed
 FROM dbo.Data;

 --3.CORRELATION AND RANKS
 --- 3.CORRELATION AND RANKS

 /* check the correlation between confirmed, deaths and recoverd case*/
 /* we can see that there is high correlation between confirmed, deaths and recoverd case, which make sense.*/
 @@ -258,43 +295,22 @@ SELECT
 FROM dbo.Data
 ORDER BY confirmed DESC;

 /*********** Median ***********/
 --To get the last value in the top 50 percent of rows.
 SELECT TOP 1 Confirmed
 FROM dbo.Data
 WHERE Confirmed IN (SELECT TOP 50 PERCENT Confirmed 
 					FROM dbo.Data
 					ORDER BY Confirmed ASC)
 ORDER BY Confirmed DESC

 /*********** Mode ***********/

 /* What is the frequently occuring numbers of confirmed cases in each month? */
 /* we can see that February 2020 are the months which have most number of confirmed case*/
 SELECT TOP 1 
 	DATEPART(YEAR, Date) AS 'Year', 
 	DATEPART(MONTH, Date) AS 'Month', 
 	confirmed
 FROM   dbo.Data
 WHERE  Confirmed IS Not NULL
 GROUP  BY DATEPART(YEAR, Date), DATEPART(MONTH, Date), confirmed
 ORDER  BY COUNT(*) DESC

 --4.LINEAR MODELS
 --- 4.LINEAR MODELS
 /***************** Linear Models ****************/
 /* Linear Model such as regression are useful for estimating values for business.
 Such as: We just run an advertising campaign and expect to sell more items than usual.
 How many employees should we have working?
 */
 /*********** Computing Slope (employee shifts on y-axis and units sold in x-asis) *********/
 Such as: We just want to estimate how much revenue we get after run a marketing campaign with xx cost.*/

 --- The result of Linear Regression: y=mx+b => y = 0.0136x + 9.9926. It means that when confirmed case increases 100 case, there will increase 1 deadth.

 /*********** Computing Slope (Deaths on y-axis and confirmed case in x-asis) *********/
 /* Result: 0.01360387 */
 SELECT (count(Confirmed)*sum(Confirmed*Deaths) - sum(Confirmed)* sum(Deaths))/(count(Confirmed)*sum(Confirmed*Confirmed) - sum(Confirmed)* sum(Confirmed))
 FROM dbo.Data

 /*********** Computing Intercept (deaths on y-axis and confirmed in x-asis) *********/ 
 /*********** Computing Intercept (deaths on y-axis and confirmed case in x-asis) *********/ 
 --Intercept = avg(y) - slope*avg(x)
 /* Result: 9.992565367 */
 SELECT AVG(Deaths) - ((count(Confirmed)*sum(Confirmed*Deaths) - sum(Confirmed)* sum(Deaths))/(count(Confirmed)*sum(Confirmed*Confirmed) - sum(Confirmed)* sum(Confirmed)))*AVG(Confirmed)
 FROM dbo.Data

 --Linear Regression: y=mx+b => y = 0.0136x + 9.9926 
