Rem
Rem $Header: rdbms/admin/execlmnr.sql /main/1 2014/12/17 08:57:27 cderosa Exp $
Rem
Rem execlmnr.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      execlmnr.sql - Set up incremental stats on Logminer tables during db creation. 
Rem
Rem    DESCRIPTION
Rem		 Set up incremental stats on Logminer tables. 
Rem			1. Set incremental stats table preferences on each 
Rem			   Logminer table.
Rem			2. Gather stats to establish incremental stats 
Rem			   (Init synopsis for each partition, etc)
Rem
Rem    NOTES
Rem	These steps are performed on upgrade across 12.1 as well as
Rem	during db creation, however these steps are only run from
Rem 	execlmnr.sql during db creation. On upgrade, these steps are 
Rem	performed in a and post upgrade scripts.
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/execlmnr.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/execlmnr.sql 
Rem    SQL_PHASE: EXECLMNR
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpend.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cderosa     07/03/14 - Script to set statistics gathering table
Rem                           preferences on logminer dictionary tables.
Rem    cderosa     07/03/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


Rem
Rem Set incremental stats preferences on Logminer tables and
Rem invoke log miner gather stats script if run during db creation.
Rem Otherwise, if in upgrade, wait to call these during upgrade scripts.
Rem

VARIABLE  logmnr_name VARCHAR2(256)
COLUMN   :logmnr_name NEW_VALUE logmnr_file NOPRINT

DECLARE
 cursor table_name_cursor  is
      select  x.name table_name
      from sys.x$krvxdta x
      where bitand(x.flags, 12) != 0;
BEGIN

   :logmnr_name := 'nothing.sql';
   IF (sys.dbms_registry.is_in_upgrade_mode()) THEN
       RETURN;  -- Get out if in upgrade mode
   END IF;
   :logmnr_name := 'execlmnrstats.sql';
   for table_name_rec in table_name_cursor loop
      begin
         DBMS_STATS.SET_TABLE_PREFS('SYSTEM', 
	 'LOGMNR_'|| table_name_rec.table_name||'', 'incremental', 'TRUE');
	 DBMS_STATS.SET_TABLE_PREFS('SYSTEM', 
	 'LOGMNR_'|| table_name_rec.table_name||'', 
	 'incremental_staleness', 'use_stale_percent, use_locked_stats');
      end;
   end loop;
END;
/

SELECT :logmnr_name FROM sys.dual;
@@&logmnr_file

@?/rdbms/admin/sqlsessend.sql
