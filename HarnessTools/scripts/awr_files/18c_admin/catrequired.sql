Rem
Rem $Header: rdbms/admin/catrequired.sql /main/2 2017/04/27 17:09:44 raeburns Exp $
Rem
Rem catrequired.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrequired.sql - Catalog Mandatory Upgrade Script
Rem
Rem    DESCRIPTION
Rem      This catalog script is a place holder
Rem      for other things that may be added in the future.
Rem      Right now it only calls catrequtlmg.sql.
Rem
Rem    NOTES
Rem      You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catrequired.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catrequired.sql
Rem    SQL_PHASE:  UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: catuppst.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       raeburns 04/14/17 - Bug 25790192: Add SQL_METADATA
Rem       jerrede  04/17/12 - Created
Rem


Rem *********************************************************************
Rem BEGIN catrequired.sql
Rem *********************************************************************

Rem
Rem Display Start TimeStamp
Rem
SELECT sys.dbms_registry_sys.time_stamp('catreq_bgn') as timestamp from dual;


Rem
Rem Post-utlmmig statistics gathering
Rem
@@catrequtlmg.sql


Rem
Rem Display End TimeStamp
Rem
SELECT sys.dbms_registry_sys.time_stamp('catreq_end') as timestamp from dual;

Rem *********************************************************************
Rem END catrequired.sql
Rem *********************************************************************

