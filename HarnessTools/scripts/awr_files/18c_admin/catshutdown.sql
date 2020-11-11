Rem
Rem $Header: rdbms/admin/catshutdown.sql /main/5 2017/04/27 17:09:44 raeburns Exp $
Rem
Rem catshutdown.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catshutdown.sql - Shut down the database
Rem
Rem    DESCRIPTION
Rem      Shutdown the database immediately.
Rem
Rem    NOTES
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catshutdown.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catshutdown.sql
Rem    SQL_PHASE:  UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: catupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/14/17 - Bug 25790192: Add SQL_METADATA
Rem    cmlim       06/19/16 - cmlim_lrg-19543910: move DBRESTART tag to
Rem                           catmmig.sql
Rem    cmlim       06/10/16 - bug 23215791: add more DBUA_TIMESTAMPS during db
Rem                           upgrades
Rem    jerrede     08/28/12 - Shutdown the Database
Rem    jerrede     08/28/12 - Created
Rem

Rem =====================================================================
Rem SHUTDOWN THE DATABASE..!!!!! 
Rem =====================================================================

Rem =====================================================================
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem =====================================================================

Rem =====================================================================
Rem Run component status as the last output
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem Note:  ACTIONS_END must stay here to get the correct upgrade time.
Rem =====================================================================

Rem
Rem Shutdown the database
Rem
shutdown immediate;

