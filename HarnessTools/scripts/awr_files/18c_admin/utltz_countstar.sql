Rem
Rem $Header: rdbms/admin/utltz_countstar.sql /main/1 2017/02/24 13:37:10 huagli Exp $
Rem
Rem utltz_countstar.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      utltz_countstar.sql - TIME ZONE Upgrade Utility Script
Rem                            Gives count of TIMESTAMP WITH TIME ZONE (TSTZ)
Rem                            columns using an explicit COUNT(*)
Rem
Rem    DESCRIPTION
Rem      Script to approximate how much TIMESTAMP WITH TIME ZONE data there is 
Rem      in a database using a COUNT(*) for each table that has a TSTZ column.
Rem	 This script is useful when using DBMS_DST package or the scripts of
Rem      utlz_upg_check.sql and utlz_upg_apply.sql scripts.
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * This script must be connected AS SYSDBA to run.
Rem      * This script is mainly useful for 11.2 and up.
Rem      * The database will NOT be restarted.
Rem      * NO downtime is needed for this script.
Rem      * NOT required for utlz_upg_check.sql and utlz_upg_apply.sql
Rem      * If your stats are up to date, then use utltz_countstats.sql 
Rem        which will use statistics information (faster).
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utltz_countstar.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utltz_countstar.sql
Rem    SQL_PHASE:
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huagli     01/12/17 - renamed to utltz_countstar.sql and added to shiphome
Rem    gvermeir   01/08/15 - renamed from countTSTZdata.sql to countstarTSTZ.sql
Rem    gvermeir   01/06/15 - only need to do one count(*) for each table
Rem    gvermeir   12/22/14 - added DISTINCT to rec
Rem    gvermeir   03/17/14 - added logging of time
Rem    gvermeir   05/13/13 - Initial release.
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET FEEDBACK OFF
SET SERVEROUTPUT ON

-- Get time
VARIABLE v_time NUMBER
EXEC :v_time := DBMS_UTILITY.GET_TIME

-- Alter session to avoid performance issues
ALTER SESSION SET NLS_SORT = 'BINARY';

-- Set client_info so one can use: 
-- select .... from V$SESSION where CLIENT_INFO = 'counttstzdata';
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('counttstzdata');
WHENEVER SQLERROR EXIT

-- Check if user is SYS
DECLARE
   v_checkvar1 VARCHAR2(10 CHAR);
BEGIN
   EXECUTE IMMEDIATE
     'SELECT SUBSTR(SYS_CONTEXT(''USERENV'',''CURRENT_USER''), 1, 10) 
      FROM dual'
   INTO v_checkvar1;

   IF v_checkvar1 = 'SYS' THEN
     NULL;
   ELSE
     DBMS_OUTPUT.PUT_LINE('ERROR: Current connection is not a ' ||
                          'sysdba connection!');
     RAISE_APPLICATION_ERROR(-20001,
                             'Stopping script - see previous message ...');
   END IF;
END;
/

WHENEVER SQLERROR CONTINUE

EXEC DBMS_OUTPUT.PUT_LINE( ' . ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Estimating amount of TSTZ data using COUNT(*). ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' This might take some time ... ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' .' );
EXEC DBMS_OUTPUT.PUT_LINE( ' For SYS tables first ... ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Note: empty tables are not listed. ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Owner.TableName.ColumnName - COUNT(*) of that column' );

DECLARE
   v_countstar	NUMBER;
   v_totalcount	NUMBER;
   v_totalcols	NUMBER; 
   v_stmt       VARCHAR2(200 CHAR);
   v_thistable	VARCHAR2(80 CHAR);
   v_prevtable	VARCHAR2(80 CHAR);
BEGIN
   v_totalcount  := TO_NUMBER('0');
   v_totalcols	 := TO_NUMBER('0');
   v_thistable	 := NULL;
   v_prevtable	 := ' ';

   FOR REC IN ( SELECT DISTINCT c.owner, c.table_name, c.column_name
		FROM dba_tab_cols c, dba_objects o
		WHERE c.owner = o.owner AND
                      c.table_name = o.object_name AND
                      c.owner = 'SYS' AND
                      c.data_type LIKE '%WITH TIME ZONE' AND
                      o.object_type = 'TABLE'
		ORDER BY c.table_name, c.column_name)
   LOOP
     v_thistable := '"' || REC.OWNER || '"."' || REC.TABLE_NAME || '"';

     IF v_prevtable != v_thistable THEN
       v_stmt := 
         'SELECT COUNT(*) FROM "' || 
         REC.OWNER || '"."' || REC.TABLE_NAME || '"';

       EXECUTE IMMEDIATE v_stmt INTO v_countstar;

       IF v_countstar > 0 THEN
         DBMS_OUTPUT.PUT_LINE(REC.OWNER || '.' || REC.TABLE_NAME || '.' || 
                              REC.COLUMN_NAME || ' - ' || v_countstar );
       END IF;
     ELSE
       IF v_countstar > 0 THEN
	 DBMS_OUTPUT.PUT_LINE(REC.OWNER || '.' || REC.TABLE_NAME || '.' || 
                              REC.COLUMN_NAME || ' - ' || v_countstar );
       END IF;
     END IF;

     v_prevtable := '"' || REC.OWNER || '"."' || REC.TABLE_NAME || '"';

     v_totalcount := v_totalcount + v_countstar;
     v_totalcols  := v_totalcols + 1;
    
   END LOOP;

   DBMS_OUTPUT.PUT_LINE(' Total count * of SYS TSTZ columns is : ' || 
                        TO_CHAR(v_totalcount));

   DBMS_OUTPUT.PUT_LINE(' There are in total '|| TO_CHAR(v_totalcols) ||
                        ' SYS TSTZ columns.'  );
END;
/

EXEC DBMS_OUTPUT.PUT_LINE( ' . ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' For non-SYS tables ... ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Note: empty tables are not listed.' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Owner.TableName.ColumnName - COUNT(*) of that column ' );

DECLARE
   v_countstar  NUMBER;
   v_totalcount	NUMBER;
   v_totalcols  NUMBER;
   v_stmt       VARCHAR2(200 CHAR);
   v_thistable	VARCHAR2(80 CHAR);
   v_prevtable	VARCHAR2(80 CHAR);	
BEGIN	
   v_totalcount  := TO_NUMBER('0');
   v_totalcols	 := TO_NUMBER('0');
   v_thistable	 := NULL;
   v_prevtable	 := ' ';

   FOR REC IN ( SELECT DISTINCT c.owner, c.table_name, c.column_name
		FROM dba_tab_cols c, dba_objects o
		WHERE c.owner = o.owner AND
                      c.table_name = o.object_name AND
                      c.owner != 'SYS' AND
                      c.data_type LIKE '%WITH TIME ZONE' AND
                      o.object_type = 'TABLE'
		ORDER BY c.owner, c.table_name, c.column_name)
   LOOP
     v_thistable := '"' || REC.OWNER || '"."' || REC.TABLE_NAME || '"';

     IF v_prevtable != v_thistable THEN
       v_stmt := 
         'SELECT COUNT(*) FROM "' || 
         REC.OWNER || '"."' || REC.TABLE_NAME || '"';

       EXECUTE IMMEDIATE v_stmt INTO v_countstar;

       IF v_countstar > 0 THEN
         DBMS_OUTPUT.PUT_LINE(REC.OWNER || '.' || REC.TABLE_NAME || '.' || 
                              REC.COLUMN_NAME || ' - ' || v_countstar );
       END IF;
     ELSE
       IF v_countstar > 0 THEN
	 DBMS_OUTPUT.PUT_LINE(REC.OWNER || '.' || REC.TABLE_NAME || '.' || 
                              REC.COLUMN_NAME || ' - ' || v_countstar );
       END IF;
     END IF;

     v_prevtable  := '"' || REC.OWNER || '"."' || REC.TABLE_NAME || '"';

     v_totalcount := v_totalcount + v_countstar;
     v_totalcols  := v_totalcols + 1;
    
   END LOOP;

   DBMS_OUTPUT.PUT_LINE(' Total count * of non-SYS TSTZ columns is :  ' || 
                        TO_CHAR(v_totalcount));

   DBMS_OUTPUT.PUT_LINE(' There are in total '|| TO_CHAR(v_totalcols) ||
                        ' non-SYS TSTZ columns.');
end;
/

-- Print time it took
EXEC :v_time :=  ROUND((DBMS_UTILITY.GET_TIME - :v_time)/100/60)
EXEC DBMS_OUTPUT.PUT_LINE(' Total Minutes elapsed : ' || :v_time)

SET FEEDBACK ON

-- End of countTSTZdata.sql

@?/rdbms/admin/sqlsessend.sql
