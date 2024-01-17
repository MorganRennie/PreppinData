-- Reunion the two dataoutputs from Week1 and generate column for Quarter
CREATE VIEW `UNIONED_WEEK2` AS
	SELECT 
    		*, 
    		QUARTER(DATE) as QUARTER 
  	FROM `prep2024_w1`.`vweek1_output1`
		UNION ALL
	SELECT 
    		*, 
    		QUARTER(DATE) as QUARTER 
  	FROM `prep2024_w1`.`vweek1_output2`

-- Create Min Table
CREATE VIEW `WEEK2_MIN` AS
	SELECT  
  		"MIN" AS `AGGREGATION`,
  		`QUARTER`,
    		`CLASS`,
    		`FLOW_CARD`,
    		MIN(PRICE) AS `MIN_PRICE`
  	FROM `UNIONED_WEEK2`
  	GROUP BY `AGGREGATION`, `QUARTER`, `CLASS`, `FLOW_CARD`;


-- Create Max Table
CREATE VIEW `WEEK2_MAX` AS
	SELECT  
  		"MAX" AS `AGGREGATION`,
  		`QUARTER`,
    		`CLASS`,
    		`FLOW_CARD`,
    		MAX(PRICE) AS `MAX_PRICE`
  	FROM `UNIONED_WEEK2`
  	GROUP BY `AGGREGATION`, `QUARTER`, `CLASS`, `FLOW_CARD`;

-- Create Median Table
CREATE VIEW `WEEK2_MEDIAN` AS
  -- Create CTE to extract the middle number in an odd list, or the two middle numbers in an even list.
	CTE AS (
		SELECT
        		QUARTER(DATE) AS `QUARTER`,
        		`CLASS`,
        		`FLOW_CARD`,
    			SUBSTRING_INDEX(
    		  		SUBSTRING_INDEX(
    			  		GROUP_CONCAT(`PRICE` ORDER BY `PRICE` SEPARATOR ',') , ',', 
    				  	(COUNT(*) + (CASE WHEN COUNT(*)%2 = 0 THEN 0 ELSE 1 END)) / 2 + ((CASE WHEN COUNT(*)%2 = 0 THEN 1 ELSE 0 END))
				), ',' ,(CASE WHEN COUNT(*)%2 = 0 THEN -2 ELSE -1 END)) 
          			AS `MED_PRICE`
		FROM `UNIONED_WEEK2`
      		GROUP BY `QUARTER`, `CLASS`, `FLOW_CARD`)
 
  -- Generate the median dataset, if the list is odd, take the value, else average the two values returned.
	SELECT
    		"MED" as `AGGREGATION`,
    		`QUARTER`,
      		`CLASS`,
      		`FLOW_CARD`,
      		CASE
        		WHEN 
          			LENGTH(MED_PRICE) - LENGTH(REPLACE(MED_PRICE, ',', '')) = -1 
        		THEN
          			CAST(MED_PRICE AS DECIMAL(10, 2))
        		ELSE
          			(CAST(SUBSTRING_INDEX(MED_PRICE, ',', 1) AS DECIMAL(10, 2)) +
           			CAST(SUBSTRING_INDEX(MED_PRICE, ',', -1) AS DECIMAL(10, 2))) / 2
        		END
        		AS MED_PRICE
    	FROM CTE;

  -- Build Final Data output
    -- BUILD CTE TO UNION AND PIVOT THE THREE AGGREGATION DATA SOURCES
	WITH CTE AS (
  	-- MIN PIVOTS
		SELECT
  			QUARTER,
      			AGGREGATION,
			FLOW_CARD,
      			SUM(CASE WHEN CLASS="Economy" THEN MIN_PRICE ELSE NULL END) AS ECONOMY,
  			SUM(CASE WHEN CLASS="Business Class" THEN MIN_PRICE ELSE NULL END) AS BUSINESS_CLASS,
  			SUM(CASE WHEN CLASS="Premium Economy" THEN MIN_PRICE ELSE NULL END) AS PREMIUM_ECONOMY,
  			SUM(CASE WHEN CLASS="First Class" THEN MIN_PRICE ELSE NULL END) AS FIRST_CLASS
  		FROM WEEK2_MIN
  		GROUP BY QUARTER, AGGREGATION, FLOW_CARD
  			UNION ALL
	-- MAX PIVOTS
		SELECT
			QUARTER,
			AGGREGATION,
    			FLOW_CARD,
			SUM(CASE WHEN CLASS="Economy" THEN MAX_PRICE ELSE NULL END) AS ECONOMY,
			SUM(CASE WHEN CLASS="Business Class" THEN MAX_PRICE ELSE NULL END) AS BUSINESS_CLASS,
			SUM(CASE WHEN CLASS="Premium Economy" THEN MAX_PRICE ELSE NULL END) AS PREMIUM_ECONOMY,
			SUM(CASE WHEN CLASS="First Class" THEN MAX_PRICE ELSE NULL END) AS FIRST_CLASS
		FROM WEEK2_MAX
		GROUP BY QUARTER, AGGREGATION, FLOW_CARD
			UNION ALL
	--MEDIAN PIVOTS
		SELECT
			QUARTER,
    			AGGREGATION,
    			FLOW_CARD,
    			SUM(CASE WHEN CLASS="Economy" THEN MED_PRICE ELSE NULL END) AS ECONOMY,
			SUM(CASE WHEN CLASS="Business Class" THEN MED_PRICE ELSE NULL END) AS BUSINESS_CLASS,
			SUM(CASE WHEN CLASS="Premium Economy" THEN MED_PRICE ELSE NULL END) AS PREMIUM_ECONOMY,
			SUM(CASE WHEN CLASS="First Class" THEN MED_PRICE ELSE NULL END) AS FIRST_CLASS
		FROM WEEK2_MEDIAN
		GROUP BY QUARTER, AGGREGATION, FLOW_CARD)
    -- END OF CTE, FINAL DATA SET CREATION FOR OUTPUT
	SELECT 
		FLOW_CARD, 
		QUARTER, 
    		AGGREGATION, 
    		ROUND(FIRST_CLASS,2) AS `ECONOMY`,
    		ROUND(BUSINESS_CLASS,2) AS `PREMIUM_ECONOMY`, 
    		ROUND(PREMIUM_ECONOMY,2) AS `BUSINESS_CLASS`,
    		ROUND(ECONOMY,2) AS `FIRST_CLASS`
	FROM CTE;
