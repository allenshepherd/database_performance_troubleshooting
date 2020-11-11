Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      pdbinput.sql - SQL*Plus script to get the data source inside a PDB
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/ashrptipdb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/ashrptipdb.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    kmorfoni   12/06/16 - specify con_dbid in AWR SQL report
Rem    arbalakr   07/14/16 - Created
Rem

set echo off verify off timing off feedback off trimspool on trimout on
set long 1000000 pagesize 6000 linesize 80


set feedback off;
set heading off;
set serveroutput on format wrapped;

BEGIN
  dbms_output.put_line('');
  dbms_output.put_line('');
  dbms_output.put_line('Specify the location of AWR Data');
  dbms_output.put_line('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  dbms_output.put_line('AWR_ROOT - Use AWR data from root (default)');
  dbms_output.put_line('AWR_PDB - Use AWR data from PDB');
END;
/

column view_loc print;

select 'Location of AWR Data Specified:', 
       upper( (case when '&&awr_location' IS NULL
                    then '&&default_awr_location'
                    when upper('&&awr_location') <> 'AWR_PDB'
                    then '&&default_awr_location'
                    else '&&awr_location' end) ) view_loc from dual;

set heading on;
set serveroutput off;
