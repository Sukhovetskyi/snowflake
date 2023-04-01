alter database that_realy_cool_sample_stuff rename to SNOWFLAKE_SAMPLE_DATA;
GRANT IMPORTED PRIVILEGES
ON DATABASE SNOWFLAKE_SAMPLE_DATA
TO ROLE SYSADMIN;


--Check the range of values in the Market Segment Column
SELECT DISTINCT c_mktsegment
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

--Find out which Market Segments have the most customers
SELECT c_mktsegment, COUNT(*)
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
GROUP BY c_mktsegment
ORDER BY COUNT(*);

---------------------------------------

-- Nations Table
SELECT N_NATIONKEY, N_NAME, N_REGIONKEY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION;

-- Regions Table
SELECT R_REGIONKEY, R_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION;

-- Join the Tables and Sort
SELECT R_NAME as Region, N_NAME as Nation
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION 
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION 
ON N_REGIONKEY = R_REGIONKEY
ORDER BY R_NAME, N_NAME ASC;

--Group and Count Rows Per Region
SELECT R_NAME as Region, count(N_NAME) as NUM_COUNTRIES
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION 
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION 
ON N_REGIONKEY = R_REGIONKEY
GROUP BY R_NAME;




-- where did you put the function?
show user functions in account;

-- did you put it here?
select * 
from snowflake.account_usage.functions
where function_name = 'GRADER'
and function_catalog = 'DEMO_DB'
and function_owner = 'ACCOUNTADMIN';

select GRADER(step,(actual = expected), actual, expected, description) as graded_results from (
SELECT 'DORA_IS_WORKING' as step
 ,(select 223 ) as actual
 ,223 as expected
 ,'Dora is working!' as description
); 




USE ROLE SYSADMIN;
CREATE DATABASE INTL_DB;
USE SCHEMA INTL_DB.PUBLIC;


CREATE WAREHOUSE INTL_WH 
WITH WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE;

USE WAREHOUSE INTL_WH;

use role accountadmin;

-- set your worksheet drop lists to the location of your GRADER function using commands
-- change the next two lines (if needed) to the location of your GRADER function
use database demo_db;
use schema public;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
 SELECT 'SMEW01' as step
 ,(select count(*) 
   from snowflake.account_usage.databases
   where database_name = 'INTL_DB' 
   and deleted is null) as actual
 , 1 as expected
 ,'Created INTL_DB' as description
 );

 CREATE OR REPLACE TABLE INTL_DB.PUBLIC.INT_STDS_ORG_3661 
(ISO_COUNTRY_NAME varchar(100), 
 COUNTRY_NAME_OFFICIAL varchar(200), 
 SOVEREIGNTY varchar(40), 
 ALPHA_CODE_2DIGIT varchar(2), 
 ALPHA_CODE_3DIGIT varchar(3), 
 NUMERIC_COUNTRY_CODE integer,
 ISO_SUBDIVISION varchar(15), 
 INTERNET_DOMAIN_CODE varchar(10)
);

CREATE OR REPLACE FILE FORMAT INTL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR 
  TYPE = 'CSV' 
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = '|' 
  RECORD_DELIMITER = '\r' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134'
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');


create or replace stage INTL_DB.PUBLIC.like_a_window_into_an_s3_bucket
url = 's3://uni-lab-files/smew/';

copy into INTL_DB.PUBLIC.INT_STDS_ORG_3661
from @INTL_DB.PUBLIC.like_a_window_into_an_s3_bucket
files = ( 'ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='PIPE_DBLQUOTE_HEADER_CR' );

SELECT count(*) as FOUND, '249' as EXPECTED 
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661; 



ALTER DATABASE INTRL_DB
RENAME TO INTL_DB;

TRUNCATE TABLE INTL_DB.PUBLIC.INT_STDS_ORG_3661;
ALTER TABLE INTRL_DB.PUBLIC.INT_3661
RENAME TO INTL_DB.PUBLIC.INT_STDS_ORG_3661;






CREATE VIEW NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
  SELECT  
    iso_country_name
    , country_name_official,alpha_code_2digit
    ,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey
;

SELECT *
FROM INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO;


CREATE TABLE INTL_DB.PUBLIC.CURRENCIES 
(
  CURRENCY_ID INTEGER, 
  CURRENCY_CHAR_CODE varchar(3), 
  CURRENCY_SYMBOL varchar(4), 
  CURRENCY_DIGITAL_CODE varchar(3), 
  CURRENCY_DIGITAL_NAME varchar(30)
)
  COMMENT = 'Information about currencies including character codes, symbols, digital codes, etc.';

CREATE TABLE INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    COUNTRY_CHAR_CODE Varchar(3), 
    COUNTRY_NUMERIC_CODE INTEGER, 
    COUNTRY_NAME Varchar(100), 
    CURRENCY_NAME Varchar(100), 
    CURRENCY_CHAR_CODE Varchar(3), 
    CURRENCY_NUMERIC_CODE INTEGER
  ) 
  COMMENT = 'Many to many code lookup table';

  CREATE FILE FORMAT INTL_DB.PUBLIC.CSV_COMMA_LF_HEADER
  TYPE = 'CSV'
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = ',' 
  RECORD_DELIMITER = '\n' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134' 
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');

create or replace stage INTL_DB.PUBLIC.like_a_window_into_an_s3_bucket
url = 's3://uni-lab-files/smew/';

copy into INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
from @INTL_DB.PUBLIC.like_a_window_into_an_s3_bucket
files = ( 'country_code_to_currency_code.csv')
file_format = ( format_name='CSV_COMMA_LF_HEADER' );



CREATE VIEW SIMPLE_CURRENCY 
( CTY_CODE,CUR_CODE) AS
  select COUNTRY_CHAR_CODE, CURRENCY_CHAR_CODE from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE;

  select * from SIMPLE_CURRENCY;

use role accountadmin;
grant override share restrictions on account to role accountadmin;

SELECT CURRENT_ACCOUNT();


ALTER VIEW INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO
SET SECURE; 

ALTER VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY
SET SECURE;


-- https://jq86994.ca-central-1.aws.snowflakecomputing.com
-- JQ86994


SHOW MANAGED ACCOUNTS;

JQ86994.ca-central-1.aws;

USE ROLE ACCOUNTADMIN;
SHOW RESOURCE MONITORS;



-- set your worksheet drop lists to the location of your GRADER function
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT 
 'SMEW08' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%366%')) as actual
 , 1 as expected
 ,'03-00-01-08' as description
UNION ALL
SELECT 
  'SMEW09' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%NCIES%')) as actual
 , 1 as expected
 ,'03-00-01-09' as description
UNION ALL
SELECT 
  'SMEW10' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%IMPLE%')) as actual
 , 1 as expected
 ,'03-00-01-10' as description
UNION ALL 
SELECT 
    'SMEW11' as step 
,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%DE_TO%')) as actual
, 1 as expected
,'03-00-01-11' as description
); 








use role SYSADMIN;
--Caden set up a new database (and you will, too)
create database ACME;

--did Snowflake set your worksheet database to the new database? 
--if not, you can do it yourself.
use database ACME;

--get rid of the public schema - too generic
drop schema PUBLIC;

--When creating shares it is best to have multiple schemas
create schema ACME.SALES;
create schema ACME.STOCK;
create schema ACME.ADU;



use role SYSADMIN;
--Lottie's team will enter new stock into this table when inventory is received
-- the Date_Sold and Customer_Id will be null until the car is sold
create or replace table ACME.STOCK.LOTSTOCK
(
 VIN VARCHAR(17)
,EXTERIOR VARCHAR(50)	
,INTERIOR VARCHAR(50)
,DATE_SOLD DATE
,CUSTOMER_ID NUMBER(20)
);

--This secure view breaks the VIN into digestible components
--this view only shares unsold cars because the unsold cars
--are the ones that need to be enhanced
create or replace secure view ACME.ADU.LOTSTOCK 
AS (
SELECT VIN
  , LEFT(VIN,3) as WMI
  , SUBSTR(VIN,4,5) as VDS
  , SUBSTR(VIN,10,1) as MODYEARCODE
  , SUBSTR(VIN,11,1) as PLANTCODE
  , EXTERIOR
  , INTERIOR
FROM ACME.STOCK.LOTSTOCK
WHERE DATE_SOLD is NULL
);


--You need a file format if you want to load the table
create file format ACME.STOCK.COMMA_SEP_HEADERROW 
TYPE = 'CSV' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1 
FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  
TRIM_SPACE = TRUE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');



--Use a COPY INTO to load the data
--the file is named Lotties_LotStock_Data.csv
create stage DEMO_DB.PUBLIC.LIKE_A_WINDOW_INTO_AN_S3_BUCKET
 url = 's3://uni-lab-files';

COPY INTO acme.stock.lotstock
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Lotties_LotStock_Data.csv')
file_format =(format_name=ACME.STOCK.COMMA_SEP_HEADERROW);


-- After loading your base table is no longer empty
-- it should now have 300 rows
select * from acme.stock.lotstock;

--the View will show just 298 rows because the view only shows
--rows where the date_sold is null
select * from acme.adu.lotstock;

alter DATABASE ACME rename to back_when_i_pretended_i_was_caden;

USE ROLE SYSADMIN;

--Max created a database to store Vehicle Identification Numbers
CREATE DATABASE max_vin;

DROP SCHEMA max_vin.public;
CREATE SCHEMA max_vin.decode;





--Create a file format and then load each of the 5 Lookup Tables
--You need a file format if you want to load the table
CREATE FILE FORMAT MAX_VIN.DECODE.COMMA_SEP_HEADERROW 
TYPE = 'CSV' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1 
FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  
TRIM_SPACE = TRUE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');



------------------------------------------
list @demo_db.public.like_a_window_into_an_s3_bucket/smew;
/*
smew/Maxs_MMVDS_Data.csv
smew/Maxs_ManufPlants_Data.csv
smew/Maxs_ManufToMake_Data.csv
smew/Maxs_ModelYear_Data.csv
smew/Maxs_WMIToManuf_data.csv
*/

COPY INTO MAX_VIN.DECODE.WMITOMANUF
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_WMIToManuf_data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MANUFTOMAKE
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_ManufToMake_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MODELYEAR
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_ModelYear_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MANUFPLANTS
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_ManufPlants_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MMVDS
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_MMVDS_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

----------------------------------------------------------------------
--Max has Lottie's VINventory table. Now he'll join his decode tables to the data
-- He'll create a select statement that ties each table into Lottie's VINS
-- Every time he adds a new table, he'll make sure he still has 298 rows

SELECT *
FROM ACME_DETROIT.ADU.LOTSTOCK l-- he uses Lottie's data from the INBOUND SHARE
JOIN MAX_VIN.DECODE.MODELYEAR y-- and confirms he can join it with his own decode data
ON l.modyearcode=y.modyearcode;


select * from ACME_DETROIT.ADU.LOTSTOCK;

SELECT *
FROM ACME_DETROIT.ADU.LOTSTOCK l-- he uses Lottie's data from the INBOUND SHARE
JOIN MAX_VIN.DECODE.WMITOMANUF w-- and confirms he can join it with his own decode data
ON l.WMI=w.WMI;
--Add the next table (still 298?)
SELECT *
FROM ACME_DETROIT.ADU.LOTSTOCK l-- he uses Lottie's data from the INBOUND SHARE
JOIN MAX_VIN.DECODE.WMITOMANUF w-- and confirms he can join it with his own decode data
ON l.WMI=w.WMI
JOIN MAX_VIN.DECODE.MANUFTOMAKE m
ON w.manuf_id=m.manuf_id;

--Until finally he has all 5 lookup tables added
--He can then remove the asterisk and start narrowing down the
--fields to include in the final output
SELECT
l.VIN
,y.MODYEARNAME
,m.MAKE_NAME
,v.DESC1
,v.DESC2
,v.DESC3
,BODYSTYLE
,ENGINE
,DRIVETYPE
,TRANS
,MPG
,MANUF_NAME
,COUNTRY
,VEHICLETYPE
,PLANTNAME
FROM ACME_DETROIT.ADU.LOTSTOCK l-- he joins Lottie's data from the INBOUND SHARE
JOIN MAX_VIN.DECODE.WMITOMANUF w-- with all his data (he just tested)
    ON l.WMI=w.WMI
JOIN MAX_VIN.DECODE.MANUFTOMAKE m
    ON w.manuf_id=m.manuf_id
JOIN MAX_VIN.DECODE.MANUFPLANTS p
    ON l.plantcode=p.plantcode
    AND m.make_id=p.make_id
JOIN MAX_VIN.DECODE.MMVDS v
    ON v.vds=l.vds
    and v.make_id = m.make_id
JOIN MAX_VIN.DECODE.MODELYEAR y
    ON l.modyearcode=y.modyearcode;




-----------------------------------------
-- Once the select statement looks good (above), Max lays a view on top of it
-- this will make it easier to use in a Stored procedure

USE ROLE SYSADMIN;
CREATE DATABASE MAX_OUTGOING;--this new database will be used for his OUTBOUND SHARE
CREATE SCHEMA MAX_OUTGOING.FOR_ACME;--this schema he creates especially for ACME


-- This is a live view of the data Lottie and Caden Need!
CREATE OR REPLACE SECURE VIEW MAX_OUTGOING.FOR_ACME.LOTSTOCKENHANCED as
(
SELECT
l.VIN
,y.MODYEARNAME
,m.MAKE_NAME
,v.DESC1
,v.DESC2
,v.DESC3
,BODYSTYLE
,ENGINE
,DRIVETYPE
,TRANS
,MPG
,EXTERIOR
,INTERIOR
,MANUF_NAME
,COUNTRY
,VEHICLETYPE
,PLANTNAME
FROM ACME_DETROIT.ADU.LOTSTOCK l
JOIN MAX_VIN.DECODE.WMITOMANUF w
    ON l.WMI=w.WMI
JOIN MAX_VIN.DECODE.MANUFTOMAKE m
    ON w.manuf_id=m.manuf_id
JOIN MAX_VIN.DECODE.MANUFPLANTS p
    ON l.plantcode=p.plantcode
    AND m.make_id=p.make_id
JOIN MAX_VIN.DECODE.MMVDS v
    ON v.vds=l.vds and v.make_id = m.make_id
JOIN MAX_VIN.DECODE.MODELYEAR y
    ON l.modyearcode=y.modyearcode
);



---------------------------------------------------
CREATE OR REPLACE TABLE MAX_OUTGOING.FOR_ACME.LOTSTOCKRETURN
(
     VIN	        VARCHAR(17)
    ,MODYEARNAME	NUMBER(4)
    ,MAKE_NAME	    VARCHAR(50)
    ,DESC1	        VARCHAR(50)
    ,DESC2	        VARCHAR(50)
    ,DESC3	        VARCHAR(50)
    ,BODYSTYLE	    VARCHAR(25)
    ,ENGINE	        VARCHAR(100)
    ,DRIVETYPE	    VARCHAR(50)
    ,TRANS	        VARCHAR(50)
    ,MPG	        VARCHAR(25)
    ,EXTERIOR	    VARCHAR(50)
    ,INTERIOR	    VARCHAR(50)
    ,MANUF_NAME	    VARCHAR(50)
    ,COUNTRY	    VARCHAR(50)
    ,VEHICLETYPE	VARCHAR(50)
    ,PLANTNAME	    VARCHAR(75)
  );
  


  --=============================STORED PROCEDURE====================================
-- Create a stored proc that will dump and reload the vinhanced table 
-- using the view that combines Lottie's data with Max's. You don't actually need 
-- two sets of variables but using two might help make it clearer for some people. 

USE ROLE SYSADMIN;

create or replace procedure lotstockupdate_sp()
  returns string not null
  language javascript
  as
  $$
    var my_sql_command1 = "truncate table max_outgoing.for_acme.lotstockreturn;";
    var statement1 = snowflake.createStatement( {sqlText: my_sql_command1} );
    var result_set1 = statement1.execute();
    
    var my_sql_command2 ="insert into max_outgoing.for_acme.lotstockreturn ";    
    my_sql_command2 += "select VIN, MODYEARNAME, MAKE_NAME, DESC1, DESC2, DESC3, BODYSTYLE";
    my_sql_command2 += ",ENGINE, DRIVETYPE, TRANS, MPG, EXTERIOR, INTERIOR, MANUF_NAME, COUNTRY, VEHICLETYPE, PLANTNAME";
    my_sql_command2 += " from max_outgoing.for_acme.lotstockenhanced;";

    var statement2 = snowflake.createStatement( {sqlText: my_sql_command2} ); 
    var result_set2 = statement2.execute(); 
    return my_sql_command2; 
   $$; 
   
   --View your Stored Procedure 
   show procedures in account; 
   desc procedure lotstockupdate_sp(); 
 
--==========SCHEDULED TASK============================================== 
-- Create a task that calls the stored procedure every hour 
-- so that Lottie sees updates at least every hour






--=== CHECK ON AND SUSPEND THE SCHEDULED TASK ========================== 
show tasks in account;
desc task acme_return_update;
 
alter task acme_return_update suspend;  
 
--Check back 5 mins later to make sure your task is NOT running
desc task acme_return_update;



insert into max_outgoing.for_acme.lotstockreturn
 select VIN, MODYEARNAME, MAKE_NAME, DESC1, DESC2, DESC3, BODYSTYLE ,ENGINE, DRIVETYPE, TRANS, MPG, EXTERIOR,
 INTERIOR, MANUF_NAME, COUNTRY, VEHICLETYPE, PLANTNAME
 from max_outgoing.for_acme.lotstockenhanced;

create or replace view DEMO_DB.PUBLIC.DETROIT_ZIPS( ZIP ) as SELECT DISTINCT(Postal_Code) 
FROM GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.STANDARD_TILE.HISTORY_DAY
where postal_code like '482%' or postal_code like '481%';

-- set the worksheet drop lists to match the location of your GRADER function
--DO NOT MAKE ANY CHANGES BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
SELECT 
  'SMEW14' as step
 ,(select count(*) 
   from DEMO_DB.PUBLIC.DETROIT_ZIPS) as actual
 , 9 as expected
 ,'Detroit Zips' as description
); 


SELECT DISTINCT(Postal_Code) 
FROM GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.STANDARD_TILE.HISTORY_DAY
where postal_code like '%482'