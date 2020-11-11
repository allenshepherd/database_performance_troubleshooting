Rem
Rem $Header: rdbms/admin/catuptabdata.sql /main/3 2017/03/20 12:21:11 raeburns Exp $
Rem
Rem catuptabdata.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catuptabdata.sql - CATalog UPgrade oracle-maintained TABle DATA
Rem
Rem    DESCRIPTION
Rem      This script runs ALTER TABLE UPGRADE statements for any
Rem      Oracle-Maintained tables that are flagged as having type data
Rem      that needs to be upgraded.  The utluptabdata.sql script performs
Rem      ALTER TABLE UPGRADE statements for customer tables that
Rem      depend on Oracle-Maintained types and need to be upgraded.
Rem
Rem    NOTES
Rem      This script must be run connected AS SYSDBA.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catuptabdata.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catuptabdata.sql 
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catuppst.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/08/17 - Bug 25616909: Use UTILITY for SQL_PHASE
Rem    raeburns    12/09/15 - Bug 22175911: remove serveroutput off, 
Rem                           improve error message
Rem    raeburns    08/24/15 - script to upgrade types in 
Rem                           Oracle-Maintained tables
Rem    raeburns    08/24/15 - Created
Rem

Rem ====================================================================
Rem BEGIN catuptabdata.sql
Rem ====================================================================

set serveroutput on

DECLARE
  CURSOR tabs IS
     SELECT DISTINCT u.name owner, o.name name
     FROM sys.obj$ o, sys.user$ u, sys.col$ c, sys.coltype$ t
     WHERE bitand(t.flags,256) = 256 AND -- NOT upgraded
           t.intcol# = c.intcol# AND
           t.col# = c.col# AND
           t.obj# = c.obj# AND
           c.obj# = o.obj# AND
           o.owner# = u.user# AND
           o.owner# IN  -- Oracle-supplied user
              (SELECT user# FROM sys.user$
               WHERE type#=1 and bitand(spare1, 256)= 256);
BEGIN
   FOR tab IN tabs LOOP
     BEGIN
       EXECUTE IMMEDIATE 'ALTER TABLE ' || 
                   dbms_assert.enquote_name(tab.owner)||
                   '.' || dbms_assert.enquote_name(tab.name) || 
                   ' UPGRADE INCLUDING DATA';
       dbms_output.put_line ('Table ' || tab.owner || '.' || 
                                         tab.name || ' upgraded.');
     EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line 
              ('Table ' || tab.owner || '.' || tab.name || ' not upgraded.');
           dbms_output.put_line
              ('..' || SUBSTR(SQLERRM, 1, 78));
     END;
   END LOOP;
END;
/

Rem ====================================================================
Rem END catuptabdata.sql
Rem ====================================================================

