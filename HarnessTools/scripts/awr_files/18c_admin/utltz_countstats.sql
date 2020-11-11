Rem
Rem $Header: rdbms/admin/utltz_countstats.sql /main/1 2017/02/24 13:37:10 huagli Exp $
Rem
Rem utltz_countstats.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      utltz_countstats.sql - TIME ZONE Upgrade Utility Script
Rem                             Gives count of TIMESTAMP WITH TIME ZONE (TSTZ)
Rem                             columns using stats info
Rem
Rem    DESCRIPTION
Rem      Script to gives how much TIMESTAMP WITH TIME ZONE data there is 
Rem      in a database using stats info. If the stats are not up to date,
Rem      use utltz_countstart.sql (slower).
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * This script must be connected AS SYSDBA to run.
Rem      * This script is mainly useful for 11.2 and up.
Rem      * The database will NOT be restarted.
Rem      * NO downtime is needed for this script.
Rem      * NOT required for utlz_upg_check.sql and utlz_upg_apply.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utltz_countstats.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utltz_countstats.sql
Rem    SQL_PHASE:
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huagli      01/31/17 - renamed to utltz_countstats.sql and added to shiphome
Rem    gvermeir    01/08/15 - created from countstarTSTZ.sql
Rem    gvermeir    01/08/15 - renamed from countTSTZdata.sql to countstarTSTZ.sql
Rem    gvermeir    01/06/14 - only need to do one count(*) for each table
Rem    gvermeir    12/22/14 - added DISTINCT to rec
Rem    gvermeir    03/17/14 - added logging of time
Rem    gvermeir    05/13/13 - Initial release.
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
-- select .... from V$SESSION where CLIENT_INFO = 'countstatsTSTZ';
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('countstatsTSTZ');
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
EXEC DBMS_OUTPUT.PUT_LINE( ' Amount of TSTZ data using num_rows stats info in DBA_TABLES.' );
EXEC DBMS_OUTPUT.PUT_LINE( ' . ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' For SYS tables first ... ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Note: empty tables are not listed.' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Stat date  - Owner.TableName.ColumnName - num_rows  ' );

DECLARE
   v_numrows	   NUMBER;
   v_totalnumrows  NUMBER;
   v_totalcols     NUMBER;
   v_lastanalyse   VARCHAR2(10 CHAR);	
   v_stmt          VARCHAR2(200 CHAR);
   v_thistable     VARCHAR2(80 CHAR);
   v_prevtable     VARCHAR2(80 CHAR);
BEGIN
   v_numrows	 	:= TO_NUMBER('0');
   v_totalnumrows 	:= TO_NUMBER('0');
   v_totalcols	 	:= TO_NUMBER('0');
   v_thistable	 	:= NULL; 
   v_prevtable	 	:= ' ';

   -- not using ALL_TSTZ_TAB_COLS since this is not known in 11.1 and lower
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
       BEGIN
         v_stmt := 
           'SELECT num_rows, TO_CHAR(last_analyzed, ''DD/MM/YYYY'')
            FROM dba_tables 
            WHERE owner = :X and table_name = :Y ';

         EXECUTE IMMEDIATE v_stmt INTO v_numrows, v_lastanalyse
         USING REC.OWNER, REC.TABLE_NAME;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           v_numrows := 0;
       END;

       IF v_numrows > 0 THEN
         DBMS_OUTPUT.PUT_LINE(v_lastanalyse || ' - ' || rec.owner || '.' || 
                              rec.table_name || '.'|| rec.column_name ||
                             ' - ' || v_numrows);
         v_totalnumrows := v_totalnumrows + v_numrows;
       END IF;
     ELSE
       IF v_numrows > 0 THEN
         DBMS_OUTPUT.PUT_LINE(v_lastanalyse || ' - ' || rec.owner || '.' || 
                              rec.table_name || '.'|| rec.column_name ||
                             ' - ' || v_numrows);
         v_totalnumrows := v_totalnumrows + v_numrows;
       END IF;
     END IF;

     v_prevtable := '"' || REC.OWNER || '"."' || REC.TABLE_NAME || '"';
     v_totalcols  := v_totalcols + 1;
    
   END LOOP;

   DBMS_OUTPUT.PUT_LINE(' Total numrows of SYS TSTZ columns is : ' || 
                        TO_CHAR(v_totalnumrows));

   DBMS_OUTPUT.PUT_LINE(' There are in total '|| TO_CHAR(v_totalcols) ||
                        ' SYS TSTZ columns.'  );
END;
/

EXEC DBMS_OUTPUT.PUT_LINE( ' . ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' For non-SYS tables ... ' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Note: empty tables are not listed.' );
EXEC DBMS_OUTPUT.PUT_LINE( ' Stat date  - Owner.Tablename.Columnname - num_rows  ' );

DECLARE
   v_numrows	   NUMBER;
   v_totalnumrows  NUMBER;
   v_totalcols     NUMBER;
   v_lastanalyse   VARCHAR2(10 CHAR);
   v_stmt          VARCHAR2(200 CHAR);
   v_thistable     VARCHAR2(80 CHAR);
   v_prevtable     VARCHAR2(80 CHAR);
BEGIN
   v_numrows	 	:= TO_NUMBER('0');
   v_totalnumrows 	:= TO_NUMBER('0');
   v_totalcols	 	:= TO_NUMBER('0');
   v_thistable	 	:= NULL;
   v_prevtable	 	:= ' ';
 
   -- not using ALL_TSTZ_TAB_COLS since this is not known in 11.1 and lower
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
       BEGIN
         v_stmt := 
           'SELECT num_rows, TO_CHAR(last_analyzed, ''DD/MM/YYYY'')
            FROM dba_tables 
            WHERE owner = :X and table_name = :Y ';


         EXECUTE IMMEDIATE v_stmt INTO v_numrows, v_lastanalyse
         USING REC.OWNER, REC.TABLE_NAME;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           v_numrows := 0;
       END;

       IF v_numrows > 0 THEN
         DBMS_OUTPUT.PUT_LINE(v_lastanalyse || ' - ' || rec.owner || '.' || 
                              rec.table_name || '.'|| rec.column_name ||
                             ' - ' || v_numrows);
         v_totalnumrows := v_totalnumrows + v_numrows;
       END IF;
     ELSE
       IF v_numrows > 0 THEN
         DBMS_OUTPUT.PUT_LINE(v_lastanalyse || ' - ' || rec.owner || '.' ||
                              rec.table_name || '.'|| rec.column_name ||
                             ' - ' || v_numrows);
         v_totalnumrows := v_totalnumrows + v_numrows;
       END IF;
     END IF;

     v_prevtable := '"' || REC.OWNER || '"."' || REC.TABLE_NAME || '"';
     v_totalcols  := v_totalcols + 1;

   END LOOP;

   DBMS_OUTPUT.PUT_LINE(' Total numrows of non-SYS TSTZ columns is : ' || 
                        TO_CHAR(v_totalnumrows));

   DBMS_OUTPUT.PUT_LINE(' There are in total '|| TO_CHAR(v_totalcols) ||
                        ' non-SYS TSTZ columns.' );
END;
/

-- Print time it took
EXEC :v_time :=  ROUND((DBMS_UTILITY.GET_TIME - :v_time)/100/60)
EXEC DBMS_OUTPUT.PUT_LINE(' Total Minutes elapsed : ' || :v_time)

SET FEEDBACK ON

-- End of countstatsTSTZ.sql

@?/rdbms/admin/sqlsessend.sql
 
