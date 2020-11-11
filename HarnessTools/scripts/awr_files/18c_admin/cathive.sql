Rem
Rem $Header: rdbms/admin/cathive.sql /main/16 2015/08/04 04:30:22 mthiyaga Exp $
Rem
Rem cathive.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cathive.sql - catalog views for hive metadata
Rem
Rem    DESCRIPTION
Rem      Scripts to create various oracle catalog views for hive metadata
Rem
Rem    NOTES
Rem      None
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cathive.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cathive.sql
Rem    SQL_PHASE: CATHIVE
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mthiyaga    07/17/15 - Move contents into cathive1.sql
Rem    mthiyaga    07/16/15 - Bug 21278506
Rem    pxwong      07/15/15 - bug 21452755 include solaris sparc
Rem    mthiyaga    06/15/15 - Prefix functions with DBMS_HADOOP
Rem    mthiyaga    05/20/15 - Bug 20736856
Rem    mthiyaga    03/21/15 - Add debugDir
Rem    yanxie      01/21/15 - bug 20339390
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    mthiyaga    10/17/14 - HIVE_TAB_PARTITIONS and HIVE_PART_KEY_COLUMNS
Rem    mthiyaga    07/12/14 - Add configDir arg to getHiveTable()
Rem    mthiyaga    06/21/14 - Catalog views for hive metastore
Rem    mthiyaga    06/21/14 - Created
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
Rem CREATE Hive catalog views conditionally
Rem ==========================================================================

VAR execfile VARCHAR2(32)
COLUMN :execfile NEW_VALUE execfile NOPRINT;

BEGIN
   IF (:pfid = 13 OR :pfid = 2) THEN
      :execfile := 'cathive1.sql';
   ELSE
      :execfile := 'nothing.sql';
   END IF;
END;
/
SELECT :execfile FROM DUAL;
@@&execfile

@@?/rdbms/admin/sqlsessend.sql

