/* Exploration */

--What range of years are represented in the data?
SELECT (MIN(year) || ' - ' || MAX(year)) AS 'Range of Years'
FROM airfare_data;

--What are the shortest and longest-distanced flights, and between which 2 cities are they?
SELECT DISTINCT city1, city2, nsmiles AS 'miles'
FROM airfare_data
WHERE nsmiles = (SELECT MIN(nsmiles) FROM airfare_data) OR
	nsmiles = (SELECT MAX(nsmiles) FROM airfare_data);
-----OR-----
SELECT city1, city2, MIN(nsmiles) as distance FROM airfare_data
UNION
SELECT city1, city2, MAX(nsmiles) as distance FROM airfare_data;

--How many distinct cities are represented in the data (source or destination)?
SELECT city1
FROM airfare_data
UNION
SELECT city2
FROM airfare_data
ORDER BY 1;

/* Analysis */

--Which airline appear most frequently as the carrier with the lowest fare(ie. carrier_low)?
SELECT carrier_low, COUNT(*) AS 'Frequency'
FROM airfare_data
WHERE carrier_low != 'NULL'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--How about the airline with  the largest market share (ie. carrier_lg)?
SELECT carrier_lg, COUNT(*) AS 'Frequency'
FROM airfare_data
WHERE carrier_low != 'NULL'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--How many instances are there where the carrier with the largest market share is not
-- the carrier with the lowest fare? What is the average difference in fare?
SELECT COUNT(carrier_lg) AS 'Num of Lg Carriers w/o Lowest Fare'
FROM airfare_data
WHERE carrier_lg != carrier_low;

/*  Intermediate Challenges */

--What is the percent change in average fare from 2007 to 2017 by flight?
--REMINDER: PERCENT CHANGE = ((value2 - value1) / value1)*100
WITH fares1 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 2007
	GROUP BY 1
),
	fares2 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 2017
	GROUP BY 1
)
SELECT 
	fares1.year, fares1.Average, fares2.year, fares2.Average,
	ROUND(((fares2.Average-fares1.Average)/fares1.Average)*100, 1) AS 'Percent Change'
FROM fares1, fares2;

--How about from 1997 to 2017?
WITH fares1 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 1997
	GROUP BY 1
),
	fares2 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 2017
	GROUP BY 1
)
SELECT 
	fares1.year, fares1.Average, fares2.year, fares2.Average,
	ROUND(((fares2.Average-fares1.Average)/fares1.Average)*100, 1) AS 'Percent Change'
FROM fares1, fares2;

--How would you describe the overall trend in airfares from 2007 to 2017, as compared 2007 to 2017?
WITH fares1 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 1997
	GROUP BY 1
),
	fares2 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 2007
	GROUP BY 1
),
	fares3 AS(
	SELECT year, ROUND(AVG(fare), 2) as 'Average'
	FROM airfare_data
	WHERE year = 2017
	GROUP BY 1
)
SELECT 
	ROUND(((fares3.Average-fares1.Average)/fares1.Average)*100, 1) AS '% Chg 1997-2017',
	ROUND(((fares3.Average-fares2.Average)/fares2.Average)*100, 1) AS '% Chg 2007-2017'
FROM fares1, fares2, fares3;

/*  Advanced Challenges  */

--What is the average fare for each quarter per year? Which quarter has the highest average fare? Lowest?
WITH Q1 AS(
	SELECT year, quarter, ROUND(AVG(fare), 2) AS 'Q1_Avg_Fare'
	FROM airfare_data
	WHERE quarter = 1
	GROUP BY 1
),
	Q2 AS(
	SELECT year, quarter, ROUND(AVG(fare), 2) AS 'Q2_Avg_Fare'
	FROM airfare_data
	WHERE quarter = 2
	GROUP BY 1
),
	Q3 AS(
	SELECT year, quarter, ROUND(AVG(fare), 2) AS 'Q3_Avg_Fare'
	FROM airfare_data
	WHERE quarter = 3
	GROUP BY 1
),
	Q4 AS(
	SELECT year, quarter, ROUND(AVG(fare), 2) AS 'Q4_Avg_Fare'
	FROM airfare_data
	WHERE quarter = 4
	GROUP BY 1
)
SELECT Q4.year, 
	Q1.Q1_Avg_Fare, Q2.Q2_Avg_Fare, Q3.Q3_Avg_Fare, Q4.Q4_Avg_Fare
FROM Q1
JOIN Q2
	ON Q1.year = Q2.year
JOIN Q3
	ON Q2.year = Q3.year
JOIN Q4
	ON Q3.year = Q4.year; 

/* Considering only flights that have data availabe on all 4 quarters of the year, 
 which quarter has the highest overall average fare? Lowest? Try breaking down by year as well. */

--Add column to table to create a unique identifier for each flight.
--ALTER TABLE airfare_data
--ADD flight_year AS (city1 || ' -> ' || city2 || '_' || year);

WITH
data1 (Year, flight, flight_year, quarter) AS(
	SELECT 
		year,
		city1 || ' -> ' || city2,
		city1 || ' -> ' || city2 || '_' || year,
		quarter
	FROM airfare_data
	GROUP BY 2,1
	HAVING COUNT(DISTINCT quarter) = 4
),
final(year, flight, quarter, fare) AS(
	SELECT airfare_data.year, data1.flight, airfare_data.quarter, airfare_data.fare
	FROM airfare_data
	JOIN data1
	ON airfare_data.flight_year = data1.flight_year)

SELECT year, flight, Quarter, ROUND(AVG(fare), 2) as AvgFare 
FROM final
GROUP BY 1, 2, 3
ORDER BY 1, 2;


