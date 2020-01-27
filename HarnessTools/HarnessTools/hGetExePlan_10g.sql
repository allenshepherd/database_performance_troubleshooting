rem $Header$
rem $Name$      HGetExePlan.sql
rem Copyright (c); 2014 by Hotsos Enterprises, Ltd.
rem ***************************************************************
rem Hotsos Get Execution Plan
rem This script accepts a single SQL statement in a file as input.
rem It then gets the file putting it into the sql*plus buffer
rem then the file is run. No output is displayed. Once it runs 
rem the execution plan is shown using DBMS_XPLAN.DISPLAY_CURSOR 
rem The script is intended to be used for queries.
rem If testing DML you may want to add a ROLLBACK at the end.
rem ***************************************************************
rem change log
rem inital writing RVD SEPT 2014
rem
rem SEVEROUTPUT must be off to get the correct SQL_ID
SET SERVEROUTPUT OFF
rem setting TAB OFF generaly makes columns line up in output better
SET TAB OFF
rem this is the line lenght, if the output wraps make this larger
SET LINESIZE 300
rem make sure we get full stats in output
ALTER SESSION SET STATISTICS_LEVEL = ALL
/
set termout on
accept sqlfile   prompt 'Enter .sql file name (without extension): '
rem Getting and running SQL statement
rem No output will be displayed
set termout off
get &sqlfile
run
rem this gets the SQL_ID and Child Number of the statement just run
COLUMN PREV_SQL_ID NEW_VALUE PSQLID
COLUMN PREV_CHILD_NUMBER NEW_VALUE PCHILDNO
select PREV_SQL_ID,PREV_CHILD_NUMBER  from v$session WHERE audsid = userenv('sessionid')
/
set termout on
rem show the SQL_ID and CHILD_NUMBER of the statement
select '&psqlid' SQL_ID, '&PCHILDNO' CHILD_NUMBER from dual
/
rem add or remove options to the display_cursor call as needed
rem these: ALLSTATS LAST COST PARTITION
rem are likely to show the most relivent info for a plan
SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR
('&psqlid','&PCHILDNO','ALLSTATS LAST COST PARTITION'))
/
SET SERVEROUTPUT ON
