Rem
Rem $Header: rdbms/admin/utluptabdata.sql /main/5 2017/03/20 12:21:11 raeburns Exp $
Rem
Rem utluptabdata.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utluptabdata.sql - UTiLity UPgrade TABle DATA
Rem
Rem    DESCRIPTION
Rem      This script upgrades customer tables that depend on
Rem      Oracle-Maintained types
Rem
Rem    NOTES
Rem      This script should be run after an upgrade to a new release
Rem      to assure that all customer tables have been upgraded to the
Rem      latest versions of Oracle-Maintained types.  In a CDB, it 
Rem      should be run in each PDB.
Rem
Rem      To successfully run this script, you must be connected
Rem      AS SYSDBA or as a user with the ALTER privilege for 
Rem      all tables to be upgraded.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/utluptabdata.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/utluptabdata.sql 
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/08/17 - Bug 25616909: Use UTILITY for SQL_PHASE
Rem    raeburns    01/22/17 - Bug 25262869: Add NOCYCLE to avoid connect by
Rem                           loops
Rem    raeburns    11/28/15 - Bug 22175911: Add Oracle-Maintained check
Rem                           Remove serveroutput off
Rem                           Improve error message
Rem    raeburns    06/05/15 - Upgrade table data for Oracle-Maintained types
Rem    raeburns    06/05/15 - Created
Rem

Rem ====================================================================
Rem BEGIN utluptabdata.sql
Rem ====================================================================

set serveroutput on

DECLARE
  CURSOR tabs IS
     SELECT DISTINCT u.name owner, o.name name
     FROM sys.obj$ o, sys.user$ u, sys.col$ c, sys.coltype$ t
     WHERE bitand(t.flags,256) = 256 AND -- UPGRADED = NO
           t.intcol# = c.intcol# AND
           t.col# = c.col# AND
           t.obj# = c.obj# AND
           c.obj# = o.obj# AND
           o.owner# = u.user# AND
           o.owner# NOT IN -- Not an Oracle-Supplied user
              (SELECT user# FROM sys.user$
               WHERE type#=1 AND bitand(spare1, 256)= 256) AND
           o.obj# IN  -- A dependent of an Oracle-Maintained type
              (SELECT do.obj# 
               FROM sys.dependency$ d, sys.obj$ do
               WHERE do.obj# = d.d_obj#
                 AND do.type# IN (2,13)
               START WITH d.p_obj# IN 
                  (SELECT obj# from sys.obj$ 
                   WHERE type#=13 AND 
                         owner# IN -- an Oracle-Supplied user 
                           (SELECT user# FROM sys.user$
                            WHERE type#=1 AND 
                            bitand(spare1, 256)= 256))             
               CONNECT BY NOCYCLE PRIOR d.d_obj# = d.p_obj#);
BEGIN
   FOR tab IN tabs LOOP
     BEGIN
       EXECUTE IMMEDIATE 'ALTER TABLE ' || 
              dbms_assert.enquote_name(tab.owner)|| '.' || 
              dbms_assert.enquote_name(tab.name) || 
              ' UPGRADE INCLUDING DATA';
       dbms_output.put_line 
              ('Table ' || tab.owner || '.' || tab.name || ' upgraded.');
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
Rem END utluptabdata.sql
Rem ====================================================================
