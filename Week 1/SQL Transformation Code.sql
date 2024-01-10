## Let us create a new scheema for the first week of 2024 Preppin' Data Challenges
CREATE SCHEMA `prep2024_w1`;

#Next, lets create a table for the input data for 2024, Week 1.
CREATE TABLE `week1_input_data` 
	(`Flight Details` text, 
	`Flow Card?` int, 
    `Bags Checked` int, 
    `Meal Type` text);

## ... and insert the data into the input table
INSERT INTO `week1_input_data` 
(`Flight Details`,
`Flow Card?`,
`Bags Checked`,
`Meal Type`) VALUES (?,?,?,?);

## We will then generate the output tables, with the only difference being the final "WHERE" clause = 0 or 1
CREATE TABLE `WEEK1_OUTPUT1` AS
	SELECT
	CAST(SUBSTRING_INDEX(`Flight Details`,'//',1) AS DATE) AS `DATE`,
	##FLIGHT_NUMBER
    SUBSTRING_INDEX(
		SUBSTRING_INDEX(`Flight Details`,'//',2)
		,'//',-1) AS 'FLIGHT_NUMBER',
	##FROM
    SUBSTRING_INDEX(
		SUBSTRING_INDEX(
			SUBSTRING_INDEX(`Flight Details`,'//',3),'//',-1)
		, '-',1) AS 'FROM',
	##TO
	SUBSTRING_INDEX(
		SUBSTRING_INDEX(
		SUBSTRING_INDEX(`Flight Details`,'//',3),'//',-1)
		, '-',-1) AS 'TO',
	##CLASS
	SUBSTRING_INDEX(
		SUBSTRING_INDEX(`Flight Details`,'//',4)
		,'//',-1) AS 'CLASS',
    ## TURN THE PRICE INTO A ONE POINT FLOAT
    CAST(SUBSTRING_INDEX(`Flight Details`,'//',-1) AS FLOAT) AS `PRICE`,
    ##TURN THE BINARY FLOW CARD INTO YES OR NO.
    CASE WHEN `Flow Card?`="1" THEN "Yes" ELSE "No" END AS `FLOW_CARD`,
    `Bags Checked` AS BAGS_CHECKED,
    `Meal Type` AS MEAL_TYPE
FROM week1
##SEPERATE INTO TWO TABLES
WHERE `Flow Card?`="0";
## WHERE `Flow Card?`="1";

##PERFORM A CHECK OF THE DATA    
SELECT * FROM WEEK1_OUTPUT1; 
