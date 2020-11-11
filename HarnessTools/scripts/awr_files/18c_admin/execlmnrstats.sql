Rem
Rem $Header: rdbms/admin/execlmnrstats.sql /main/1 2014/12/17 08:57:27 cderosa Exp $
Rem
Rem execlmnrstats.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      execlmnrstats.sql - Gather stats on Logminer dictionary tables.
Rem
Rem    DESCRIPTION
Rem      Gather stats on Logminer dictionary tables. This is the first
Rem      time stats are called after incremental prefs are set, so this 
Rem 	 will set up the incremental infrastructure.
Rem
Rem    NOTES
Rem      This is called during db creation and during upgrade across 12.1
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/execlmnrstats.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/execlmnrstats.sql 
Rem    SQL_PHASE: EXECLMNRSTATS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/execlmnr.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cderosa     07/03/14 - Initial statistics gathering after incremental
Rem                           table prefs are set.
Rem    cderosa     07/03/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
DECLARE
 	cursor table_name_cursor  is
      		select  x.name table_name
      		from sys.x$krvxdta x
      		where bitand(x.flags, 12) != 0;
 	filter_lst DBMS_STATS.OBJECTTAB := DBMS_STATS.OBJECTTAB();
 	obj_lst    DBMS_STATS.OBJECTTAB := DBMS_STATS.OBJECTTAB();
	ind number := 1;
BEGIN
   for rec in table_name_cursor loop
      begin
	filter_lst.extend(1);
	filter_lst(ind).ownname := 'SYSTEM';
	filter_lst(ind).objname := 'LOGMNR_'|| rec.table_name||'';
	ind := ind + 1;
      end;
   end loop;
   DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME=>'SYSTEM', objlist=>obj_lst, obj_filter_list=>filter_lst);
END;
/
@?/rdbms/admin/sqlsessend.sql
