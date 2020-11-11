Rem
Rem $Header: rdbms/admin/catupshd.sql /main/4 2017/03/20 12:21:11 raeburns Exp $
Rem
Rem catupshd.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupshd.sql - CATalog UPgrade SHutDown
Rem
Rem    DESCRIPTION
Rem      This script is the final step in upgrades that that do not 
Rem      run utlmmig.sql.  It updates logminer metadata in the redo
Rem      stream (when needed) and shuts down the database.
Rem
Rem    NOTES
Rem      Invoked from catupend.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupshd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupshd.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmmig.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/08/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    jerrede     04/22/13 - Support for CDB
Rem    dvoss       02/16/12 - bug 13719292 - logminer build is needed
Rem                           when there is no migration
Rem    rburns      07/12/07 - final upgrade shutdown
Rem    rburns      07/12/07 - Created
Rem


Rem =====================================================================
Rem Update Logminer Metadata in Redo Stream
Rem =====================================================================

@@utllmup



