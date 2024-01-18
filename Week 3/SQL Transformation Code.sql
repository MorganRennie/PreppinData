-- Create our four targets tables
	CREATE TABLE WEEK3_Q1_TARGETS 
		(`MONTH` TEXT, 
		 `CLASS` TEXT, 
		 `TARGET` INT);

	CREATE TABLE WEEK3_Q2_TARGETS 
		(`MONTH` TEXT, 
		 `CLASS` TEXT, 
		 `TARGET` INT);

	CREATE TABLE WEEK3_Q3_TARGETS 
		(`MONTH` TEXT, 
		 `CLASS` TEXT, 
		 `TARGET` INT);
		 
	CREATE TABLE WEEK3_Q4_TARGETS 
		(`MONTH` TEXT, 
		 `CLASS` TEXT, 
		 `TARGET` INT);

-- insert the values into our tables
	INSERT INTO WEEK3_Q1_TARGETS 
	VALUES
		('1','FC',120000),
		('2','FC',130000),
		('3','FC',140000),
		('1','BC',85000),
		('2','BC',86000),
		('3','BC',87000),
		('1','PE',40000),
		('2','PE',40500),
		('3','PE',41000),
		('1','E',31000),
		('2','E',31500),
		('3','E',32000);

	INSERT INTO WEEK3_Q2_TARGETS
	VALUES
		('4', 'FC', '160000'),
		('5', 'FC', '170000'),
		('6', 'FC', '180000'),
		('4', 'BC', '88000'),
		('5', 'BC', '89000'),
		('6', 'BC', '90000'),
		('4', 'PE', '42500'),
		('5', 'PE', '43000'),
		('6', 'PE', '43500'),
		('4', 'E', '34000'),
		('5', 'E', '34500'),
		('6', 'E', '35000');

	INSERT INTO WEEK3_Q3_TARGETS
	VALUES
		('7', 'FC', '190000'),
		('8', 'FC', '200000'),
		('9', 'FC', '210000'),
		('7', 'BC', '92000'),
		('8', 'BC', '93000'),
		('9', 'BC', '95000'),
		('7', 'PE', '46000'),
		('8', 'PE', '46500'),
		('9', 'PE', '47000'),
		('7', 'E', '37000'),
		('8', 'E', '37500'),
		('9', 'E', '38000');
		
	INSERT INTO WEEK3_Q4_TARGETS
	VALUES
		('10', 'FC', '220000'),
		('11', 'FC', '230000'),
		('12', 'FC', '240000'),
		('10', 'BC', '98000'),
		('11', 'BC', '99000'),
		('12', 'BC', '100000'),
		('10', 'PE', '48000'),
		('11', 'PE', '48500'),
		('12', 'PE', '49000'),
		('10', 'E', '39000'),
		('11', 'E', '39500'),
		('12', 'E', '40000');

	CREATE TABLE `week3_unioned_output` AS
	WITH CTE AS 
		(SELECT 
			*
		FROM `prep2024_w1`.`week1_output_no`
			UNION ALL
		SELECT 
			*
		FROM `prep2024_w1`.`week1_output_yes`)
-- end cte
	SELECT
		month(DATE) AS MONTH, 
		CASE 
			WHEN CLASS="First Class" THEN "ECONOMY"
			WHEN CLASS="Business Class" THEN "PREMIUM_ECONOMY"
			WHEN CLASS="Premium Economy" THEN "BUSINESS_CLASS"
			WHEN CLASS="Economy" THEN "FIRST_CLASS"
			END AS CLASS,
		FLOW_CARD,
		PRICE
	FROM CTE;

	CREATE VIEW WEEK3_FLIGHTINFO AS
	SELECT
		MONTH,
		CONCAT(
			LEFT(CLASS,1),
			MID(CLASS,
				(CASE WHEN LOCATE("_",CLASS)="" 
				THEN LOCATE("_",CLASS)
				ELSE LOCATE("_",CLASS)+1
				END) 
				,1)) 
			AS CLASSCONCAT, 
		SUM(PRICE) AS PRICE
	FROM week3_unioned_output
	GROUP BY CLASSCONCAT, MONTH;

-- UNION QUARTER TARGETS
	CREATE VIEW WEEK3_TARGETS AS
	SELECT * FROM week3_q1_targets	
		UNION ALL
	SELECT * FROM week3_q2_targets	
		UNION ALL
	SELECT * FROM week3_q3_targets	
		UNION ALL
	SELECT * FROM week3_q4_targets;

-- CREATE FINAL OUPUT
	CREATE VIEW WEEK3_OUTPUT AS
	SELECT
		A.MONTH AS DATE,
		B.CLASS,
		A.PRICE,
		B.TARGET,
		SUM(B.TARGET-A.PRICE) AS DIFFERENCE_TO_TARGET
	FROM week3_flightinfo AS A
		JOIN WEEK3_TARGETS AS B
			ON A.MONTH = B.MONTH AND A.CLASSCONCAT = B.CLASS
	GROUP BY DATE, B.CLASS, A.PRICE, B.TARGET;
