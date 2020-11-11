Rem
Rem $Header: rdbms/admin/catnodpaq.sql /main/1 2017/07/31 11:05:56 bwright Exp $
Rem
Rem catnodpaq.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     catnodpaq.sql - Drop all DataPump AQ tables
Rem
Rem    DESCRIPTION 
Rem
Rem    NOTES
Rem     This script only gets executed from downgrade and patching (dpload), 
Rem     not during upgrade as the DBMS_ADADM package is not around then.  
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem     SQL_SOURCE_FILE: rdbms/admin/catnodpaq.sql
Rem     SQL_SHIPPED_FILE: rdbms/admin/catnodpaq.sql
Rem     SQL_PHASE: DOWNGRADE
Rem     SQL_STARTUP_MODE: DOWNGRADE
Rem     SQL_IGNORABLE_ERRORS: NONE
Rem     SQL_CALLING_FILE: rdbms/admin/catnodpall.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    bwright   07/06/17 - Created, separated from catnodp.
Rem
----------------------------------------------
---     Drop DataPump queue tables 
----------------------------------------------
DECLARE
  qt_name varchar2(128);
  CURSOR c1 IS SELECT table_name FROM dba_tables WHERE
    owner = 'SYS' AND table_name LIKE 'KUPC$DATAPUMP_QUETAB%';
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO qt_name;
    EXIT WHEN c1%NOTFOUND;
    dbms_aqadm.drop_queue_table(queue_table => 'SYS.' || qt_name,
                                force       => TRUE);
  END LOOP;
  CLOSE c1;
EXCEPTION
  WHEN OTHERS THEN
    CLOSE c1;
    IF SQLCODE = -24002 THEN 
      NULL;
    ELSE 
      RAISE;
    END IF;
END;
/
