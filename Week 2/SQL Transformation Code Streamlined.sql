-- Reduced execution duration by 7%
-- Reduced lines of code by 20, reduced views created from 5 to 3, streamliend logic.

-- FUNCTIONS USED:
-- CREATE VIEW, CREATE TABLE, CTE, UNION ALL, CASE/WHEN, CAST, SUBSTRING_INDEX, GROUP_CONCAT

-- UNION AND CORRECT INPUT DATA
    CREATE TABLE `WEEK2_UNIONED_OUTPUT` AS
	WITH CTE AS 
		(SELECT 
    			*, 
    			QUARTER(DATE) as QUARTER 
		FROM `WEEK1_OUTPUT_NO`
			UNION ALL
		SELECT 
    			*, 
    			QUARTER(DATE) as QUARTER 
		FROM WEEK1_OUTPUT_YES)
-- END CTE, CORRECT DATA
	SELECT 
		QUARTER, 
		CASE 
			WHEN CLASS="First Class" THEN "ECONOMY"
			WHEN CLASS="Business Class" THEN "PREMIUM_ECONOMY"
			WHEN CLASS="Premium Economy" THEN "BUSINESS_CLASS"
			WHEN CLASS="Economy" THEN "FIRST_CLASS"
			END AS NEW_CLASS,
		FLOW_CARD,
        	CAST(PRICE AS DECIMAL (10,2)) AS NEW_PRICE
	FROM CTE
	GROUP BY QUARTER, NEW_CLASS, FLOW_CARD, PRICE;

-- CREATE AGGREGATE TABLES
	CREATE VIEW `WEEK2_AGG` AS
  -- Create CTE to extract the middle number in an odd list, or the two middle numbers in an even list.
	WITH CTE AS (
	SELECT
        	`QUARTER`,
        	NEW_CLASS AS `CLASS`,
        	`FLOW_CARD`,
               	MIN(NEW_PRICE) AS MIN_PRICE,
               	MAX(NEW_PRICE) AS MAX_PRICE,
    		SUBSTRING_INDEX(
    		  	SUBSTRING_INDEX(
    			  	GROUP_CONCAT(`NEW_PRICE` ORDER BY `NEW_PRICE` SEPARATOR ',') , ',', 
    				(COUNT(*) + (CASE WHEN COUNT(*)%2 = 0 THEN 0 ELSE 1 END)) / 2 + ((CASE WHEN COUNT(*)%2 = 0 THEN 1 ELSE 0 END))
				), ',' ,(CASE WHEN COUNT(*)%2 = 0 THEN -2 ELSE -1 END)) 
          			AS `MED_PRICE`
	FROM `WEEK2_UNIONED_OUTPUT`
      	GROUP BY `QUARTER`, `CLASS`, `FLOW_CARD`)
 
  -- Generate the median dataset, if the list is odd, take the value, else average the two values returned.
	SELECT
    		`QUARTER`,
      		`CLASS`,
      		`FLOW_CARD`,
           	`MIN_PRICE`,
            	`MAX_PRICE`,
      		CAST(CASE
        		WHEN 
          			LENGTH(MED_PRICE) - LENGTH(REPLACE(MED_PRICE, ',', '')) = -1 
        		THEN
          			CAST(MED_PRICE AS DECIMAL(10, 2))
        		ELSE
          			(CAST(SUBSTRING_INDEX(MED_PRICE, ',', 1) AS DECIMAL(10, 2)) +
           			CAST(SUBSTRING_INDEX(MED_PRICE, ',', -1) AS DECIMAL(10, 2))) / 2
        		END
        		AS DECIMAL(10,2)) AS MED_PRICE	
    	FROM CTE;

-- Generate Output
	CREATE VIEW WEEK2_OUTPUT AS
    	SELECT 
		"MED" AS AGGREGATION,
        	QUARTER,
        	FLOW_CARD,
		SUM(CASE WHEN CLASS="ECONOMY" THEN MED_PRICE ELSE NULL END) AS ECONOMY,
		SUM(CASE WHEN CLASS="BUSINESS_CLASS" THEN MED_PRICE ELSE NULL END) AS BUSINESS_CLASS,
		SUM(CASE WHEN CLASS="PREMIUM_ECONOMY" THEN MED_PRICE ELSE NULL END) AS PREMIUM_ECONOMY,
		SUM(CASE WHEN CLASS="FIRST_CLASS" THEN MED_PRICE ELSE NULL END) AS FIRST_CLASS
	FROM WEEK2_AGG
        GROUP BY AGGREGATION, QUARTER, FLOW_CARD
		UNION ALL
        SELECT 
		"MIN" AS AGGREGATION,
        	QUARTER,
        	FLOW_CARD,
		SUM(CASE WHEN CLASS="ECONOMY" THEN MIN_PRICE ELSE NULL END) AS ECONOMY,
		SUM(CASE WHEN CLASS="BUSINESS_CLASS" THEN MIN_PRICE ELSE NULL END) AS BUSINESS_CLASS,
		SUM(CASE WHEN CLASS="PREMIUM_ECONOMY" THEN MIN_PRICE ELSE NULL END) AS PREMIUM_ECONOMY,
		SUM(CASE WHEN CLASS="FIRST_CLASS" THEN MIN_PRICE ELSE NULL END) AS FIRST_CLASS
	FROM WEEK2_AGG
        GROUP BY AGGREGATION, QUARTER, FLOW_CARD
		UNION ALL
	SELECT 
		"MAX" AS AGGREGATION,
      	  	QUARTER,
       	 	FLOW_CARD,
		SUM(CASE WHEN CLASS="ECONOMY" THEN MAX_PRICE ELSE NULL END) AS ECONOMY,
		SUM(CASE WHEN CLASS="BUSINESS_CLASS" THEN MAX_PRICE ELSE NULL END) AS BUSINESS_CLASS,
		SUM(CASE WHEN CLASS="PREMIUM_ECONOMY" THEN MAX_PRICE ELSE NULL END) AS PREMIUM_ECONOMY,
		SUM(CASE WHEN CLASS="FIRST_CLASS" THEN MAX_PRICE ELSE NULL END) AS FIRST_CLASS
	FROM WEEK2_AGG
        GROUP BY AGGREGATION, QUARTER, FLOW_CARD;