Rem
Rem $Header: rdbms/admin/sdoupgrdses.sql /main/4 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem sdoupgrdses.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sdoupgrdses.sql - SDO UPGRaDe SESsion script
Rem
Rem    DESCRIPTION
Rem      This script initializes parallel processes for the SDO upgrade.
Rem
Rem    NOTES
Rem      Invoked by catctl.pl for all processes used for the SDO upgrade.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sdoupgrdses.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sdoupgrdses.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    frealvar    07/30/16 - Bug 24332006 added missing metadata
Rem    raeburns    05/29/15 - Bug 21153626: ignore ORA-01435 if component not
Rem                           installed
Rem    raeburns    12/20/14 - SDO session script
Rem    raeburns    12/20/14 - Created
Rem

Rem Set identifier to SDO for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'SDO';

BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA=MDSYS';
EXCEPTION
  WHEN OTHERS THEN 
     IF SQLCODE = -1435 THEN NULL;
     ELSE RAISE;
     END IF;
END;
/

