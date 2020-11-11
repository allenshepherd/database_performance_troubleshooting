Rem
Rem $Header: rdbms/admin/catpses.sql /main/5 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem catpses.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpses.sql - CATalog and CATProc SESsion script
Rem
Rem    DESCRIPTION
Rem      This script initializes the session for running catalog 
Rem      and/or catproc scripts
Rem
Rem    NOTES
Rem      It is used as the session script for parallel processes
Rem      when catalog.sql and/or catproc.sql is run using multiprocesses
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpses.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpses.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cdstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/23/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    jerrede     06/03/15 - Remove Session End we do not want to set
Rem                           ORACLE_SCRIPT to false for session files in the
Rem                           upgrade
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jerrede     05/08/12 - Added session info for CDB.
Rem    rburns      10/23/06 - add session script
Rem    rburns      10/23/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem =====================================================================
Rem Assure CHAR semantics are not used in the dictionary
Rem =====================================================================
ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;


