Rem
Rem $Header: rdbms/admin/olstrig.sql /main/8 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olstrig.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olstrig.sql - Disable and Enable policies on tables to 
Rem      recreate triggers. Should be run only when OLS is configured on DB.
Rem
Rem    DESCRIPTION
Rem      The script is run at the end of Database upgrade from releases
Rem      11.2 to current release. It recreates DML triggers
Rem      on tables which have Label Security policies applied.
Rem      
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olstrig.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olstrig.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/olsdbmig.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    anupkk      06/01/16 - Bug 23346378: Internalize SQL query
Rem    risgupta    05/31/16 - Bug 23498536: Change recreate_triggers_upgrade 
Rem                           call
Rem    anupkk      04/03/16 - Bug 22917286: Changes made to consolidate
Rem                           olstrig.sql from post upgrade to upgrade
Rem    pmojjada    02/05/15 - Bug# 20421634: Long identifier changes
Rem    aramappa    04/28/10 - bug 9555367: use dbms_assert
Rem    srtata      04/16/09 - update description to indicate downgrade action
Rem    srtata      08/06/04 - srtata_bug-3803121
Rem    srtata      16/07/04 - Created
Rem

BEGIN
  LBACSYS.lbac_services.recreate_triggers_upgrade;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END;
/

show errors;
