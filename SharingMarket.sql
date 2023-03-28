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