Rem 
Rem $Header: rdbms/admin/odmproc.sql /main/4 2017/05/28 22:46:07 stanaya Exp $ template.tsc 
Rem 
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem NAME
Rem    ODMPROC.SQL
Rem
Rem
Rem NOTES
Rem    This script validates Data Mining objects and exc JSP for 10i Release One 
Rem
Rem    Script to be run as SYS. 
Rem  
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/odmproc.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/odmproc.sql
Rem    SQL_PHASE: UTILITY 
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem   MODIFIED    (MM/DD/YY)  
Rem   mmcracke     04/01/05 - Migrate ODM to SYS. 
Rem   xbarr        11/01/04 - fix bug-3936558, remove public grant for validation 
Rem   xbarr        06/25/04 - xbarr_dm_rdbms_migration
Rem   xbarr        07/17/03 - add grant statement 
Rem   fcay         06/23/03 - Update copyright notice
Rem   xbarr        02/03/03 - update validation  
Rem   xbarr        10/07/02 - xbarr_txn104649
Rem   xbarr        09/25/02 - creation
Rem
Rem ========================================================================================

Rem  Migration validation procedure
Rem
create or replace procedure validate_odm
AS
   v_count NUMBER;
   v_schema varchar2(30);
BEGIN 
  select count(*) into v_count from all_objects where object_name like 'DM%' and status = 'INVALID';
IF v_count = 0 
THEN
   sys.dbms_registry.valid('ODM');
ELSE
   sys.dbms_registry.invalid('ODM');
END IF;
END validate_odm;
/
commit;

Rem grant execute on validate_odm to public;
Rem commit;

