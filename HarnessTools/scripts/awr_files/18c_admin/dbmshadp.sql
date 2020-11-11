Rem
Rem $Header: rdbms/admin/dbmshadp.sql /main/12 2015/08/04 04:30:22 mthiyaga Exp $
Rem
Rem dbmshadp.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshadp.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmshadp.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmshadp.sql
Rem    SQL_PHASE: DBMSHADP
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: ORA-04043, ORA-00942
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mthiyaga    07/17/15 - Move contents into dbmshadp1.sql
Rem    pxwong      07/15/15 - bug 21452755 include solaris sparc
Rem    mthiyaga    07/08/15 - Move internal function defs to prvthadoop.sql
Rem    mthiyaga    06/12/15 - Move functions into package
Rem    mthiyaga    03/31/15 - Add SYNC_PARTITIONS_FOR_HIVE()
Rem    prakumar    03/25/15 - lrg#15643296: Change C17 from CLOB to Anydata
Rem    mthiyaga    03/21/15 - Add debugDir
Rem    prakumar    03/05/15 - Bug 20655337 : Add C17 of CLOB type
Rem    mthiyaga    12/09/14 - Add callType for partition info
Rem    mthiyaga    07/28/14 - Restrict DBMS_HADOOP to Linux only
Rem    mthiyaga    07/11/14 - Package specification for DBMS_HADOOP
Rem    mthiyaga    07/11/14 - Created
Rem
@@?/rdbms/admin/sqlsessstart.sql

VAR pfid NUMBER;
DECLARE
  pfid     NUMBER := 0;
BEGIN
  SELECT platform_id INTO pfid FROM v$database;
  :pfid := pfid;
END;
/

Rem ==========================================================================
Rem CREATE DBMS_HADOOP_INTERNAL and DBMS_HADOOP packages conditionally
Rem ==========================================================================

VAR execfile VARCHAR2(32)
COLUMN :execfile NEW_VALUE execfile NOPRINT;

BEGIN
   IF (:pfid = 13 or :pfid = 2) THEN
      :execfile := 'dbmshadp1.sql';
   ELSE
      :execfile := 'nothing.sql';
   END IF;
END;
/
SELECT :execfile FROM DUAL;
@@&execfile

@@?/rdbms/admin/sqlsessend.sql

