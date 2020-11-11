Rem
Rem $Header: rdbms/admin/utllmup.sql /main/5 2017/05/28 22:46:12 stanaya Exp $
Rem
Rem utllmup.sql
Rem
Rem Copyright (c) 2003, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utllmup.sql - Logminer Metadata Update
Rem
Rem    DESCRIPTION
Rem      This script should be run at the end of upgrade to write 
Rem      dictionary information to the redo stream for use by logminer
Rem      clients such as Streams.
Rem
Rem      Running an upgrade will automatically execute this script at
Rem      the very end of the ugprade process.
Rem
Rem      If a user manually re-executes portions of the upgrade script
Rem      after the main upgrade is complete, this script should also be
Rem      run to manually update the logminer metadata.
Rem
Rem    NOTES
Rem      This script will not do anything if minimal supplemental logging
Rem      and log archiving are not both enabled.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utllmup.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utllmup.sql
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/12/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    jnesheiw    02/22/05 - Remove constant 
Rem    dvoss       08/23/04 - incorrect check for sup log 
Rem    qiwang      01/18/03 - qiwang_logmnr_ckpt_conv
Rem    dvoss       01/14/03 - Created
Rem

declare
  rowcnt number;
begin
    SELECT COUNT(1) into rowcnt
    FROM SYS.V$DATABASE V
    WHERE V.LOG_MODE = 'ARCHIVELOG' and
          V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO';
    IF 0 != rowcnt THEN
      dbms_logmnr_d.build(options=>4);
    END IF;
end;
/
