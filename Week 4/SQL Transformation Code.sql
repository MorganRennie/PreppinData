-- CREATE TABLES
CREATE TABLE WEEK4_FLOW_CARD (CUSTOMER_ID INT, SEAT INT, `ROW` INT, CLASS CHAR);
CREATE TABLE WEEK4_NON_FLOW_CARD_1 (CUSTOMER_ID INT, SEAT INT, `ROW` INT, CLASS CHAR);
CREATE TABLE WEEK4_NON_FLOW_CARD_2 (CUSTOMER_ID INT, SEAT INT, `ROW` INT, CLASS CHAR);
CREATE TABLE WEEK4_SEAT_PLAN (CLASS CHAR, SEAT INT,`ROW` INT);

-- INPUT VALUES (TRUNCATED FOR EASE OF READING)
INSERT INTO WEEK4_FLOW_CARD VALUES (?,?,?,?);
INSERT INTO WEEK4_NON_FLOW_CARD_1 VALUES (?,?,?,?);
INSERT INTO WEEK4_NON_FLOW_CARD_2 VALUES (?,?,?,?);
INSERT INTO WEEK4_SEAT_PLAN VALUES (?,?,?,?);

-- there are multiple ways to complete the identification of flow_card holders.

--this first way updates the entire Flow_card table
ALTER TABLE week4_flow_card
  ADD FLOW_CARD TEXT NOT NULL DEFAULT ('Yes');

-- Another way is to do this inline, within each union, creating an identifier
CREATE VIEW WEEK4_BOOKINGS AS
  SELECT 
	  *
  FROM WEEK4_FLOW_CARD
	  UNION ALL
  SELECT
	  *, "No" AS FLOW_CARD
  FROM WEEK4_NON_FLOW_CARD_1
	  UNION ALL
  SELECT
	  *, "No" AS FLOW_CARD
  FROM WEEK4_NON_FLOW_CARD_2;

-- CREATE THE FIRST VIEW, TO SEE THE TOTAL BOOKINGS FOR EACH CLASS|ROW|SEAT|FLOWCARD
CREATE VIEW WEEK4_TOTAL_BOOKINGS AS
  SELECT
	  A.CLASS,
    A.ROW,
    A.SEAT,
    A.FLOW_CARD,
    COUNT(*) AS TOTAL_BOOKINGS
  FROM WEEK4_BOOKINGS AS A
  GROUP BY SEAT, `ROW`, CLASS, FLOW_CARD;

-- CREATE THE FINAL OUTPUT TABLE 
CREATE VIEW WEEK4_OUTPUT AS
  SELECT 
    A.CLASS,
    A.SEAT, 
    A.ROW
	FROM WEEK4_SEAT_PLAN AS A
	  LEFT JOIN WEEK4_TOTAL_BOOKINGS AS B
		  ON A.CLASS=B.CLASS 
      AND A.SEAT=B.SEAT 
      AND A.ROW=B.ROW
	WHERE TOTAL_BOOKINGS IS NULL;
