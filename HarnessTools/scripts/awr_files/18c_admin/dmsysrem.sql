Rem
Rem $Header: rdbms/admin/dmsysrem.sql /main/3 2017/05/28 22:46:05 stanaya Exp $
Rem
Rem dmsysrem.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dmsysrem.sql - Data Mining DMSYS schema and associated objects removal
Rem
Rem    DESCRIPTION
Rem      DMSYS schema has been migrated to SYS in 11gR1 release. 
Rem      The schema should be removed if the database has been 
Rem      upgraded to RDBMS release 11gR1 or above with no downgrade requirement
Rem
Rem      After removing DMSYS schema, ODM entry will be removed from 
Rem      DBA registry.
Rem      ODM cannot be downgraded to 10.2 release afterwards.
Rem
Rem    NOTES
Rem      The script must be run as SYS. 
Rem 
Rem      This script is invoked by ~rdbms/admin/catuppst.sql as part of 
Rem      12g post-upgrade actions. 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dmsysrem.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dmsysrem.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng  08/19/15 - Migrate to dbms_id
Rem    xbarr     10/25/10 - Created
Rem

set serveroutput on;

DECLARE
        dmsys_exists char(1);
	synonym_n dbms_id;
	owner_n dbms_id;
	tablename_n dbms_id;
	v_cnt integer := 0;
	d_cnt integer := 0;
	sql_text varchar2(1024);
	d_cur integer;
	v_cur integer;
	v_err_msg  varchar2(4000);

--- Drop public synonyms owned by DMSYS

        cursor synonym_cursor is
	select synonym_name, table_owner, table_name from DBA_SYNONYMS
	where table_owner = 'DMSYS'
	order by synonym_name;
  BEGIN
        DBMS_OUTPUT.ENABLE(NULL); 
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Drop DMSYS public synonyms');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
	open synonym_cursor;
	fetch synonym_cursor into synonym_n, owner_n, tablename_n;
	while synonym_cursor%FOUND loop
     BEGIN
 	sql_text := 'drop public synonym ' ||
                       dbms_assert.enquote_name(synonym_n) || ' FORCE' ;
        DBMS_OUTPUT.PUT_LINE (sql_text);
 	d_cur := dbms_sql.open_cursor;
 	dbms_sql.parse(d_cur, sql_text, dbms_sql.native);
 	v_cur := dbms_sql.execute(d_cur);
 	d_cnt := d_cnt + 1;     
     EXCEPTION
     WHEN OTHERS THEN
       v_err_msg := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK(), 1, 4000);
       DBMS_OUTPUT.PUT_LINE ('Drop failed: ' || 
                             'Synonym: "' || synonym_n || '"  ' ||
                             'Table Name: ' || tablename_n || ' ' ||
                             'Error: ' || v_err_msg );
     END;
       dbms_sql.close_cursor(d_cur);

      v_cnt := v_cnt + 1;
      fetch synonym_cursor into synonym_n, owner_n, tablename_n;
 end loop;
 close synonym_cursor;

  IF (v_cnt > 0 or d_cnt > 0) THEN
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE
      ('Total number of dmsys synonyms: ' || v_cnt );    
    DBMS_OUTPUT.PUT_LINE
      ('Total number of dmsys synonyms dropped: ' || d_cnt );
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
  END IF;

--- drop DMSYS schema if exists

  BEGIN
      EXECUTE IMMEDIATE 'select null from sys.user$ where name=''DMSYS'''
        INTO dmsys_exists;
        EXECUTE IMMEDIATE 'drop user dmsys cascade';
        DBMS_OUTPUT.PUT_LINE('DMSYS schema has been dropped');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
  END;
END;
/

set serveroutput off
